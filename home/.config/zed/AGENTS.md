# Personal agent instructions

## RTK — Rust Token Killer

`rtk` is a token-optimized CLI proxy installed on this machine. It runs the real
command and filters the output, cutting 60-90% of the tokens on typical dev
operations.

**Zed has no tool-use hook, so nothing rewrites commands for you.** When you run
a terminal command that rtk covers, prefix it with `rtk` yourself.

```bash
rtk git status          # instead of: git status
rtk read src/main.rs    # instead of: cat src/main.rs
rtk grep -r TODO src/   # instead of: grep -r TODO src/
```

### Covered commands

Prefix any of these with `rtk`; flags are passed through to the real tool.

| Area | Subcommands |
| --- | --- |
| Files | `ls` `tree` `read` `find` `grep` `rg` `wc` `diff` `json` |
| Git / forges | `git` `gh` `glab` `gt` |
| JS / TS | `npm` `npx` `pnpm` `tsc` `lint` `prettier` `vitest` `jest` `next` `playwright` `prisma` |
| Python | `pytest` `ruff` `mypy` `pip` |
| Other langs | `cargo` `go` `golangci-lint` `dotnet` `mvn` `gradlew` `rake` `rspec` `rubocop` |
| Infra | `docker` `kubectl` `oc` `aws` `psql` `curl` `wget` |
| Generic | `err` (errors only) `test` (failures only) `log` (dedup) `summary` `deps` `env` `format` |

Anything not in this list runs unchanged — do not invent rtk subcommands.

### Meta commands

```bash
rtk gain              # token savings analytics
rtk gain --history    # command history with per-command savings
```

### Getting the output rtk truncated

When rtk cuts output short it tees the **complete** unfiltered result to a log
and prints the command to read the rest:

```
  +64 more in src/foo.ts [see remaining: tail -n +26 ~/Library/Application Support/rtk/tee/1786118067_grep_0_foo_ts.log]
```

Run that `tail` — do not re-run the original command. The log holds the full
output, and `tail -n +N` skips the part you already have, so you only pay for
what you haven't seen.

Logs rotate (20 kept, 1 MB each), so fetch it in the same turn you see the
pointer. No pointer means nothing was dropped.

### Skipping the filter up front

If you already know filtering will break things — you're parsing the output, or
exact formatting matters — don't clean up afterwards, bypass it:

```bash
rtk proxy <cmd>       # unfiltered, still tracked
rtk run '<cmd>'       # raw via sh -c, no filtering, no tracking
```
