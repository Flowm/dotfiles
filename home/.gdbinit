################################################################################
# General
################################################################################

# Pretty syntax
set disassembly-flavor intel

# ASLR
set disable-randomization off

set confirm off
set verbose off
set backtrace past-main on

################################################################################
# Style
################################################################################

set pagination off
set print demangle on
set print asm-demangle off
set print pretty on
set print array on
set print object on
set print vtbl on
set print symbol-filename off
set prompt \001\033[32m\002gdb>>\001\033[0m\002\040
set output-radix 0x10

################################################################################
# History
################################################################################

set history save
set history filename ~/.gdb_history
set history save on
set history size 10000
set history expansion on

################################################################################
# Logging
################################################################################

set logging file ~/.gdb_log
set logging overwrite off
set logging redirect off
set logging on

################################################################################
# Funcs
################################################################################

define ps
    if sizeof(void*) == 8
        # x86_64
        printf "\n"
        echo \033[32m
        x/6i $pc
        echo \033[0m
        printf "\n"
        printf "rdi%16lx rsi%16lx rdx%16lx rcx%16lx\n", $rdi, $rsi, $rdx, $rcx
        printf "rax%16lx rbx%16lx r8 %16lx r9 %16lx\n", $rax, $rbx, $r8,  $r9
        printf "r10%16lx r11%16lx r12%16lx r13%16lx\n", $r10, $r11, $r12, $r13
        printf "rbp%16lx rsp%16lx r14%16lx r15%16lx\n", $rbp, $rsp, $r14, $r15
        info registers eflags
        printf "\n"
        printf "  %#018lx %#018lx %#018lx %#018lx\n", *((long*)$sp - 8),  *((long*)$sp - 7),  *((long*)$sp - 6),  *((long*)$sp - 5)
        printf "  %#018lx %#018lx %#018lx %#018lx\n", *((long*)$sp - 4),  *((long*)$sp - 3),  *((long*)$sp - 2),  *((long*)$sp - 1)
        printf "=>%#018lx %#018lx %#018lx %#018lx\n", *((long*)$sp + 0),  *((long*)$sp + 1),  *((long*)$sp + 2),  *((long*)$sp + 3)
        printf "  %#018lx %#018lx %#018lx %#018lx\n", *((long*)$sp + 4),  *((long*)$sp + 5),  *((long*)$sp + 6),  *((long*)$sp + 7)
        printf "  %#018lx %#018lx %#018lx %#018lx\n", *((long*)$sp + 8),  *((long*)$sp + 9),  *((long*)$sp + 10), *((long*)$sp + 11)
        printf "  %#018lx %#018lx %#018lx %#018lx\n", *((long*)$sp + 12), *((long*)$sp + 13), *((long*)$sp + 14), *((long*)$sp + 15)
        printf "  %#018lx %#018lx %#018lx %#018lx\n", *((long*)$sp + 16), *((long*)$sp + 17), *((long*)$sp + 18), *((long*)$sp + 19)
        printf "  %#018lx %#018lx %#018lx %#018lx\n", *((long*)$sp + 20), *((long*)$sp + 21), *((long*)$sp + 22), *((long*)$sp + 23)
        printf "\n"
    else
        # x86
        printf "\n"
        echo \033[32m
        x/6i $pc
        echo \033[0m
        printf "\n"
        printf "eax: %8x      ebx: %8x      ecx: %8x      edx: %8x\n", $eax, $ebx, $ecx, $edx
        printf "edi: %8x      esi: %8x      ebp: %8x      esp: %8x\n", $edi, $esi, $ebp, $esp
        printf "\n"
        printf "  %#010x %#010x %#010x %#010x\n", *((int*)$sp - 4),  *((int*)$sp - 3),  *((int*)$sp - 2),  *((int*)$sp - 1)
        printf "=>%#010x %#010x %#010x %#010x\n", *((int*)$sp + 0),  *((int*)$sp + 1),  *((int*)$sp + 2),  *((int*)$sp + 3)
        printf "  %#010x %#010x %#010x %#010x\n", *((int*)$sp + 4),  *((int*)$sp + 5),  *((int*)$sp + 6),  *((int*)$sp + 7)
        printf "  %#010x %#010x %#010x %#010x\n", *((int*)$sp + 8),  *((int*)$sp + 9),  *((int*)$sp + 10), *((int*)$sp + 11)
        printf "  %#010x %#010x %#010x %#010x\n", *((int*)$sp + 12), *((int*)$sp + 13), *((int*)$sp + 14), *((int*)$sp + 15)
        printf "\n"
    end
end
document ps
    Print useful information about the most important registers.
    Dump the current stack.
end

define np
    n
    x/10i $rip
end

define nps
    n
    ps
end

define nip
    ni
    x/10i $rip
end

define nips
    ni
    ps
end

define sip
    si
    x/10i $rip
end

define sips
    si
    ps
end

define ip
    x/10i $rip
end

################################################################################
# Hooks
################################################################################

# Don't promt on exit
define hook-quit
    set confirm off
end

#define hook-stop
#    x/1i $pc
#end

################################################################################
# Plugins
################################################################################

source ~/.gdb/peda/peda.py
source ~/.gdb/Pwngdb/pwngdb.py
source ~/.gdb/Pwngdb/angelheap/gdbinit.py

################################################################################
# Plugin hooks
################################################################################

define hook-run
    python
    import angelheap
    angelheap.init_angelheap()
end
end

################################################################################
# Plugin Funcs
################################################################################
define hh
    heapinfo
    parseheap
    x/10gx (long)&main_arena + 0x58
end

################################################################################
# Includes
################################################################################

# GNU Libc debug
# sudo apt install glibc-source && cd /usr/src/glibc && sudo unp /usr/src/glibc/glibc-2.19.tar.xz
#dir /usr/src/glibc/glibc-2.19/malloc
