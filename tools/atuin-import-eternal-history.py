#!/usr/bin/env python3
"""Import the myconf eternal shell history into the atuin database.

The eternal history is written by home/.shcfg/env as one tab separated record
per executed command:

    2015-07-09-19-11-19<TAB>flake<TAB>zsh<TAB>685<TAB>flow<TAB>la
    |                       |         |       |      |      |
    local time              host      shell   pid    user   command

Records are inserted straight into the atuin sqlite database, following the
conventions of atuin's own importers: an unknown working directory becomes
"unknown", an unknown exit status becomes -1 and the duration stays 0.  Unlike
those importers this tool keeps the recorded host, user and shell instead of
attributing every command to the machine running the import, and it rebuilds
shell sessions from the recorded pids.

Every imported row is placed at a sub second offset derived from the record
itself, which serves three purposes: the record always lands on the same
nanosecond no matter which files a run happens to cover, commands recorded in
the same second no longer collide in atuin's unique(timestamp, cwd, command)
index, and imported rows stay distinguishable from everything atuin wrote
itself, since atuin records either a real working directory or a whole second.
That makes an import undoable without a backup:

    delete from history where cwd = 'unknown' and timestamp % 1000000000 != 0

Both histories can be recorded side by side, which is what happens while atuin
is rolled out host by host.  A command is then written twice, and the copy atuin
already has is left out, matched per host within a few seconds.  Hosts without
atuin keep importing while the ones that have it stop where atuin took over.

Repeated runs and overlapping sets of files are safe: identical records collapse
into one and row ids are derived from the record, so re-importing inserts
nothing.  Note that this makes deletions in atuin temporary, since atuin deletes
a command outright rather than leaving a tombstone -- a command deleted there
comes back on the next import unless --exclude keeps it out.

Timestamps carry no timezone.  They are read as local time of the machine
running the import, including the DST rules in effect on the recorded date,
unless --tz (or --host-tz for a single host) names a timezone to use instead.
Records whose timezone is corrected later import a second time, at the corrected
timestamp.

Only lines that start with a timestamp are read.  A multi line command written
verbatim therefore imports as its first line: the rest cannot be attached to it
reliably, because bin/mch merges the per host files with `cat | sort -u`, which
sorts those lines away from the record they belong to, and attaching them to
whichever record ends up next to them would corrupt that command.

A record may instead hold its newlines as 0x1e, the ASCII record separator,
which keeps it on one line and survives that merge.  Those are restored to real
newlines, so the command reaches atuin whole and matches what atuin recorded for
it.  The byte does not appear anywhere in a decade of history written the old
way, so it says by itself which records were escaped: nothing else needs to be
marked, and nothing already recorded is read differently.

Needs python 3.9 (zoneinfo, plus tzdata on a minimal Linux image) and sqlite
3.25.  Never run `atuin history dedup` on a database holding these rows: it
deduplicates on (command, cwd, hostname) and every imported row shares the same
working directory, which would collapse a decade of history into one row per
command.
"""

import argparse
import hashlib
import math
import os
import re
import sqlite3
import sys
from datetime import datetime, timedelta
from pathlib import Path
from zoneinfo import ZoneInfo

RECORD_RE = re.compile(r"^\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2}\t")
EMBEDDED_RECORD_RE = re.compile(r"\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2}\t")
TS_FORMAT = "%Y-%m-%d-%H-%M-%S"
HISTORY_GLOB = "*_eternal_history"

# The ASCII record separator, holding a newline inside a one line record.
NEWLINE_ESCAPE = "\x1e"

NS = 1_000_000_000
UNKNOWN_CWD = "unknown"
UNKNOWN_EXIT = -1
UNKNOWN_DURATION = 0
# Rows are written in chunks so that a shell recording into the same database
# waits milliseconds for the write lock instead of the whole run.
CHUNK = 50_000
# Hosts listed in the per host breakdown before the rest is summed up.
HOST_ROWS = 15

# Columns to write, in atuin's own order.  Which of them exist depends on the
# atuin version, so the schema decides what is actually used.
INSERT_COLUMNS = ["id", "timestamp", "duration", "exit", "command", "cwd", "session", "hostname", "deleted_at",
                  "author", "intent", "shell"]
INTEGER_COLUMNS = {"timestamp", "duration", "exit", "deleted_at"}


class Stats:
    def __init__(self):
        self.files = 0
        self.lines = 0
        self.records = 0
        self.ignored = 0
        self.repaired = 0
        self.unusable = 0
        self.stripped_nul = 0
        self.unescaped = 0
        self.excluded = 0
        self.filtered = 0
        self.collapsed = 0
        self.sessions = 0
        self.recorded_by_atuin = 0
        self.inserted = 0
        self.skipped = 0


def parse_args(argv):
    repo = Path(__file__).resolve().parent.parent
    parser = argparse.ArgumentParser(
        description="Import the myconf eternal shell history into atuin.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "examples:\n"
            "  %(prog)s --dry-run\n"
            "  %(prog)s ~/.myconf/tmp/history\n"
            "  %(prog)s --host-tz www530.your-server.de=UTC --exclude 'password=' tmp/history\n"
        ),
    )
    parser.add_argument(
        "paths",
        nargs="*",
        type=Path,
        default=[repo / "history"],
        help=f"history files or directories to import (default: {repo / 'history'})",
    )
    parser.add_argument("--db", type=Path, help="atuin history database (default: $ATUIN_DB_PATH or the atuin data dir)")
    parser.add_argument("--tz", help="timezone the timestamps were recorded in (default: this machine's)")
    parser.add_argument(
        "--host-tz",
        action="append",
        default=[],
        metavar="HOST=ZONE",
        help="timezone override for a single host, repeatable",
    )
    parser.add_argument("--since", metavar="DATE", help="skip records before DATE (YYYY-MM-DD, in --tz)")
    parser.add_argument("--until", metavar="DATE", help="skip records after DATE (YYYY-MM-DD, in --tz)")
    parser.add_argument(
        "--exclude",
        action="append",
        default=[],
        metavar="REGEX",
        help="never import commands matching REGEX, repeatable",
    )
    parser.add_argument(
        "--dedup-window",
        type=int,
        default=2,
        metavar="SECONDS",
        help="leave out a record when atuin has the same command on the same host within this many "
        "seconds, 0 to import it anyway (default: %(default)s)",
    )
    parser.add_argument(
        "--session-gap",
        type=int,
        default=4 * 3600,
        metavar="SECONDS",
        help="start a new session after this idle time within one pid (default: %(default)s)",
    )
    parser.add_argument("--per-host", action="store_true", help="list every host, not just the largest ones")
    parser.add_argument("--dry-run", action="store_true", help="report what would be imported, write nothing")
    parser.add_argument("--no-backup", action="store_true", help="do not copy the database before writing to it")
    args = parser.parse_args(argv)

    for name in ("dedup_window", "session_gap"):
        if getattr(args, name) < 0:
            parser.error(f"--{name.replace('_', '-')} cannot be negative")
    args.host_zones = {}
    for entry in args.host_tz:
        host, _, zone = entry.partition("=")
        if not host or not zone:
            parser.error(f"--host-tz expects HOST=ZONE, got {entry!r}")
        args.host_zones[host] = parse_zone(zone, parser)
    # None means local time, resolved with the platform's historical DST rules.
    args.zone = parse_zone(args.tz, parser) if args.tz else None
    args.since_ns = day_bound_ns(args.since, args.zone, parser, end=False)
    args.until_ns = day_bound_ns(args.until, args.zone, parser, end=True)
    try:
        args.excludes = [re.compile(pattern) for pattern in args.exclude]
    except re.error as err:
        parser.error(f"bad --exclude regex: {err}")
    return args


def parse_zone(name, parser):
    try:
        return ZoneInfo(name)
    except Exception as err:
        parser.error(f"unknown timezone {name!r}: {err}")


def day_bound_ns(value, zone, parser, end):
    if value is None:
        return None
    try:
        day = datetime.strptime(value, "%Y-%m-%d")
    except ValueError:
        parser.error(f"expected a YYYY-MM-DD date, got {value!r}")
    return epoch_ns(day + timedelta(days=1) if end else day, zone)


def epoch_ns(naive, zone):
    """Read a naive timestamp as wall clock time in zone, local time if None.

    Ambiguous times (the hour a DST fall back repeats) resolve to their first
    occurrence, times skipped by a DST spring forward to the instant after the
    jump.
    """
    seconds = naive.timestamp() if zone is None else naive.replace(tzinfo=zone).timestamp()
    return int(math.floor(seconds)) * NS


def default_db_path():
    env = os.environ.get("ATUIN_DB_PATH")
    if env:
        return Path(env).expanduser()
    data_dir = os.environ.get("ATUIN_DATA_DIR")
    if not data_dir:
        xdg = os.environ.get("XDG_DATA_HOME") or Path.home() / ".local" / "share"
        data_dir = Path(xdg) / "atuin"
    return Path(data_dir).expanduser() / "history.db"


def collect_files(paths):
    files = []
    for path in paths:
        if path.is_dir():
            files.extend(sorted(p for p in path.glob(HISTORY_GLOB) if p.is_file()))
        elif path.is_file():
            files.append(path)
        else:
            sys.exit(f"error: no such file or directory: {path}")
    if not files:
        sys.exit(f"error: no {HISTORY_GLOB} files found in: {', '.join(map(str, paths))}")
    return files


def identify(second_ns, host, user, pid, command):
    """Place a record inside its second and give it an id, from the record alone.

    The offset spreads the commands recorded in the same second over the second,
    which atuin's unique(timestamp, cwd, command) index would otherwise collapse
    into one row.  Deriving it from the record rather than from the record's
    position in the run is what keeps an import stable: the same record always
    lands on the same nanosecond and keeps the same id, so importing it again
    changes nothing, whichever files the run covers.  Offset zero is left to
    atuin's own importers, which write whole seconds.

    Two records hashing to the same nanosecond would collapse into one row, at a
    chance of one in a billion per pair of commands recorded in the same second.
    No pair in the history this was written for collides.
    """
    digest = hashlib.sha256(f"{host}\x00{user}\x00{pid}\x00{second_ns}\x00{command}".encode()).digest()
    timestamp_ns = second_ns + int.from_bytes(digest[:4], "big") % (NS - 1) + 1
    # atuin's ids are opaque; the uuid v7 layout keeps them ordered like its own.
    raw = bytearray((timestamp_ns // 1_000_000 & ((1 << 48) - 1)).to_bytes(6, "big") + digest[4:14])
    raw[6] = (raw[6] & 0x0F) | 0x70
    raw[8] = (raw[8] & 0x3F) | 0x80
    return timestamp_ns, raw.hex()


def split_record(line):
    """Split a record into its fields, repairing interleaved writes.

    Records are appended from a backgrounded subshell, so a few out of a million
    were torn apart by a concurrent write: either the timestamp is preceded by
    the remains of another record, or a complete record is embedded in what looks
    like a command.  Both leave a record whose tail is intact and whose head was
    lost when it was written, so the tail is kept and the head dropped.
    """
    original = line.split("\t", 5)
    torn = len(original) != 6 or not original[3].isdigit()
    if not torn and not EMBEDDED_RECORD_RE.search(original[5]):
        return original, False
    for match in EMBEDDED_RECORD_RE.finditer(line, 1):
        fields = line[match.start():].split("\t", 5)
        if len(fields) == 6 and fields[3].isdigit() and not EMBEDDED_RECORD_RE.search(fields[5]):
            return fields, True
    return (None, False) if torn else (original, False)


def read_records(files, args, stats):
    """Yield (second_ns, command, host, user, shell, pid) in recorded order."""
    for path in files:
        stats.files += 1
        # A decade of history across hundreds of hosts contains a few broken
        # encodings and a few NUL bytes from interleaved writes.
        lines = path.read_bytes().decode("utf-8", "replace").split("\n")
        if lines and lines[-1] == "":
            lines.pop()
        stats.lines += len(lines)
        for line in lines:
            if not RECORD_RE.match(line):
                stats.ignored += 1
                continue
            fields, repaired = split_record(line.rstrip("\r"))
            if fields is None:
                stats.unusable += 1
                continue
            stats.repaired += repaired
            record = build_record(fields, args, stats)
            if record:
                yield record


def build_record(fields, args, stats):
    stamp, host, shell, pid, user, command = fields
    if NEWLINE_ESCAPE in command:
        command = command.replace(NEWLINE_ESCAPE, "\n")
        stats.unescaped += 1
    if "\x00" in command:
        command = command.replace("\x00", "")
        stats.stripped_nul += 1
    command = command.strip()
    if not command:
        stats.unusable += 1
        return None
    try:
        second_ns = epoch_ns(datetime.strptime(stamp, TS_FORMAT), args.host_zones.get(host, args.zone))
        pid = int(pid)
        # sqlite stores signed 64 bit integers; a torn timestamp can exceed that.
        if not -(2**62) < second_ns < 2**62 or not 0 <= pid < 2**31:
            raise ValueError("out of range")
    except (ValueError, OverflowError, OSError):
        stats.unusable += 1
        return None
    stats.records += 1
    if any(pattern.search(command) for pattern in args.excludes):
        stats.excluded += 1
        return None
    if args.since_ns is not None and second_ns < args.since_ns:
        stats.filtered += 1
        return None
    if args.until_ns is not None and second_ns >= args.until_ns:
        stats.filtered += 1
        return None
    return second_ns, command, host, user, shell, pid


def with_sessions(records, gap_seconds, stats):
    """Attach a session id to every record, rebuilt from the recorded pids.

    A pid identifies a shell, but pids are recycled and the same pid shows up on
    every host, so a session is a run of commands from one (host, user, pid) with
    no gap longer than gap_seconds.  The id derives from the session's first
    record, which keeps it stable across runs.
    """
    gap_ns = gap_seconds * NS
    open_sessions = {}
    for second_ns, command, host, user, shell, pid in records:
        key = (host, user, pid)
        state = open_sessions.get(key)
        if state is None or not 0 <= second_ns - state[0] <= gap_ns:
            _, session = identify(second_ns, host, user, pid, "session")
        else:
            session = state[1]
        open_sessions[key] = (second_ns, session)
        yield second_ns, command, host, user, shell, pid, session


def fill_rows(conn, columns, records, stats):
    """Collect the atuin rows to write in a temp table, keyed by row id.

    Records that are identical down to the pid share an id and collapse into one
    row, which is what makes overlapping sets of files safe: bin/mch leaves a
    merged copy of a host's file next to the one still being appended to.  Two
    runs of one command within a second in a single shell are indistinguishable
    from that and collapse as well, at a rate of about one record in twenty
    thousand.
    """
    definitions = ", ".join(
        f"{column} {'integer' if column in INTEGER_COLUMNS else 'text'}{' primary key' if column == 'id' else ''}"
        for column in columns
    )
    conn.execute(f"CREATE TEMP TABLE rows_out ({definitions})")
    statement = f"INSERT OR IGNORE INTO rows_out VALUES ({', '.join('?' for _ in columns)})"
    batch = []
    staged = 0

    def flush():
        nonlocal staged
        conn.execute("BEGIN")
        conn.executemany(statement, batch)
        conn.execute("COMMIT")
        staged += len(batch)
        batch.clear()

    for second_ns, command, host, user, shell, pid, session in records:
        timestamp_ns, row_id = identify(second_ns, host, user, pid, command)
        row = {
            "id": row_id,
            "timestamp": timestamp_ns,
            "duration": UNKNOWN_DURATION,
            "exit": UNKNOWN_EXIT,
            "command": command,
            "cwd": UNKNOWN_CWD,
            "session": session,
            "hostname": f"{host}:{user}",
            "deleted_at": None,
            "author": user,
            "intent": None,
            "shell": shell,
        }
        batch.append([row[column] for column in columns])
        if len(batch) >= CHUNK:
            flush()
    if batch:
        flush()
    stats.collapsed = staged - conn.execute("SELECT count(*) FROM rows_out").fetchone()[0]
    stats.sessions = conn.execute("SELECT count(DISTINCT session) FROM rows_out").fetchone()[0]


def drop_recorded_by_atuin(conn, columns, window_seconds, stats):
    """Leave out the rows atuin recorded itself, one for one and per host.

    atuin timestamps a command when it starts, and so does the eternal history
    hook in zsh: both run in preexec, and the eternal record is the same second
    or the one before, never further away in the history this was written for.
    Under bash the eternal record is written from PROMPT_COMMAND once the command
    has finished, so it can be a whole command duration late; a row atuin
    recorded from bash is therefore also matched against the moment its command
    ended.  Only from bash, since widening the window for every shell would let
    a long running command claim the times it ran again while it was running.

    Every row atuin wrote claims the nearest imported row for the same command
    on the same host, and claims at most one, so a command atuin saw once does
    not remove the times it ran again seconds later.  A multi line command
    reaches the eternal history as its first line, so a row atuin holds in full
    also claims that first line, which would otherwise be imported next to it.

    A row counts as atuin's own when it has a real working directory (atuin
    recording live) or sits on a whole second (atuin's own importers).  Imported
    rows are neither, so re-importing does not match itself.
    """
    where = f"(cwd != ? OR timestamp % {NS} = 0)"
    if "deleted_at" in columns:
        where += " AND deleted_at IS NULL"
    if {"duration", "shell"} <= set(columns):
        ended = "CASE WHEN shell = 'bash' THEN timestamp + max(duration, 0) ELSE timestamp END"
    else:
        ended = "timestamp"
    conn.execute(
        f"CREATE TEMP TABLE native AS SELECT hostname, command, timestamp, {ended} AS ended "
        f"FROM history WHERE {where}",
        (UNKNOWN_CWD,),
    )
    conn.execute("CREATE INDEX rows_out_match ON rows_out (hostname, command, timestamp)")
    window_ns = window_seconds * NS
    claim = conn.cursor()
    for hostname, command, started, ended in conn.execute("SELECT hostname, command, timestamp, ended FROM native"):
        wanted = [command]
        head = command.split("\n", 1)[0].strip()
        if head and head != command:
            wanted.append(head)
        claim.execute(
            f"SELECT id FROM rows_out WHERE hostname = ? AND command IN ({', '.join('?' * len(wanted))}) "
            "AND (timestamp BETWEEN ? AND ? OR timestamp BETWEEN ? AND ?) "
            "ORDER BY min(abs(timestamp - ?), abs(timestamp - ?)) LIMIT 1",
            (hostname, *wanted, started - window_ns, started + window_ns,
             ended - window_ns, ended + window_ns, started, ended),
        )
        row = claim.fetchone()
        if row:
            claim.execute("DELETE FROM rows_out WHERE id = ?", (row[0],))
            stats.recorded_by_atuin += 1


def drop_already_imported(conn, stats):
    """Drop the rows the database already holds, leaving only what is new.

    A row is already there when its id matches, which is what makes a repeated
    run a no-op, or when it would collide with atuin's unique index on
    (timestamp, cwd, command).
    """
    cursor = conn.execute(
        """
        DELETE FROM rows_out WHERE
            EXISTS (SELECT 1 FROM history h WHERE h.id = rows_out.id)
            OR EXISTS (SELECT 1 FROM history h WHERE h.timestamp = rows_out.timestamp
                       AND h.cwd = rows_out.cwd AND h.command = rows_out.command)
        """
    )
    stats.skipped = cursor.rowcount


def history_columns(conn):
    """The columns to write, so that older or newer atuin schemas still work."""
    available = {row[1] for row in conn.execute("PRAGMA table_info(history)")}
    if not available:
        sys.exit("error: no history table in the database, run atuin once to create it")
    return [column for column in INSERT_COLUMNS if column in available]


def insert_rows(conn, columns, stats):
    """Write the collected rows, in chunks so the write lock is never held long."""
    column_list = ", ".join(f'"{column}"' for column in columns)
    highest = conn.execute("SELECT coalesce(max(rowid), 0) FROM rows_out").fetchone()[0]
    for start in range(0, highest, CHUNK):
        conn.execute("BEGIN")
        cursor = conn.execute(
            f"INSERT OR IGNORE INTO history ({column_list}) "
            f"SELECT {column_list} FROM rows_out WHERE rowid > ? AND rowid <= ? ORDER BY rowid",
            (start, start + CHUNK),
        )
        stats.inserted += cursor.rowcount
        conn.execute("COMMIT")


def backup(db_path):
    """Copy the database, replacing the copy from a previous run.

    A history database holds credentials that were typed on a command line, so
    the copy is created with the same private permissions the original has.
    """
    target = db_path.with_suffix(db_path.suffix + ".bak")
    target.unlink(missing_ok=True)
    os.close(os.open(target, os.O_CREAT | os.O_WRONLY, 0o600))
    source = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    destination = sqlite3.connect(target)
    with destination:
        source.backup(destination)
    source.close()
    destination.close()
    return target


def report(conn, stats, args, db_path):
    lines = [
        ("Files read", stats.files),
        ("Lines read", stats.lines),
        ("Records parsed", stats.records),
        ("  lines without a timestamp ignored", stats.ignored),
        ("  torn records repaired", stats.repaired),
        ("  records dropped as unusable", stats.unusable),
        ("  multi line commands restored", stats.unescaped),
        ("  commands with NUL bytes removed", stats.stripped_nul),
        ("  records matching --exclude", stats.excluded),
        ("  records outside the date range", stats.filtered),
        ("  identical records collapsed", stats.collapsed),
        ("Sessions rebuilt from pids", stats.sessions),
        ("Rows atuin had recorded itself",
         stats.recorded_by_atuin if args.dedup_window else "check disabled by --dedup-window 0"),
        (f"Rows already imported into {db_path.name}", stats.skipped),
        ("Rows " + ("that would be imported" if args.dry_run else "imported"), stats.inserted),
    ]
    if stats.inserted:
        span = conn.execute("SELECT min(timestamp), max(timestamp) FROM rows_out").fetchone()
        stamps = [datetime.fromtimestamp(value / NS).strftime("%F") for value in span]
        lines.append(("Covering", f"{stamps[0]} to {stamps[1]}"))
    width = max(len(label) for label, _ in lines)
    for label, value in lines:
        print(f"{label:<{width}}  {value}")
    report_hosts(conn, args.per_host)


def report_hosts(conn, show_all):
    """Break the rows down by the host that recorded them.

    Which hosts a run brings in is the question the report is asked while atuin
    is rolled out: the hosts still feeding the eternal history are the ones that
    do not have atuin yet.
    """
    rows = conn.execute(
        "SELECT hostname, count(*), min(timestamp), max(timestamp) FROM rows_out GROUP BY hostname ORDER BY 2 DESC, 1"
    ).fetchall()
    if not rows:
        return
    listed = rows if show_all else rows[:HOST_ROWS]
    print()
    width = max(len(hostname) for hostname, *_ in listed)
    for hostname, count, low, high in listed:
        first, last = (datetime.fromtimestamp(value / NS).strftime("%F") for value in (low, high))
        print(f"  {hostname:<{width}}  {count:>7}  {first} to {last}")
    rest = rows[len(listed):]
    if rest:
        print(f"  and {len(rest)} more hosts, {sum(count for _, count, *_ in rest)} rows (--per-host lists them)")


def main(argv=None):
    args = parse_args(argv)
    db_path = (args.db or default_db_path()).expanduser()
    if not db_path.exists():
        sys.exit(f"error: no atuin database at {db_path}")
    files = collect_files(args.paths)

    uri = f"file:{db_path}?mode=ro" if args.dry_run else f"file:{db_path}"
    conn = sqlite3.connect(uri, uri=True, isolation_level=None)
    conn.execute("PRAGMA busy_timeout = 30000")
    columns = history_columns(conn)

    zones = args.tz or "local time"
    if args.host_zones:
        zones += ", " + ", ".join(f"{host} {zone}" for host, zone in args.host_zones.items())
    print(f"Reading {len(files)} history files as {zones}, writing to {db_path}")

    stats = Stats()
    fill_rows(conn, columns, with_sessions(read_records(files, args, stats), args.session_gap, stats), stats)
    if args.dedup_window:
        drop_recorded_by_atuin(conn, columns, args.dedup_window, stats)

    drop_already_imported(conn, stats)
    collected = conn.execute("SELECT count(*) FROM rows_out").fetchone()[0]
    if args.dry_run:
        stats.inserted = collected
    else:
        if collected and not args.no_backup:
            print(f"Copied the database to {backup(db_path)}")
        insert_rows(conn, columns, stats)
    report(conn, stats, args, db_path)
    conn.close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
