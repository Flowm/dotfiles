set disassembly-flavor intel
set pagination off
set follow-fork-mode child
catch fork
catch exec

set output-radix 16

define hook-stop
    if sizeof(void*) == 8
        # x86_64.
        printf "\n"
        echo \033[32m
        x/4i $pc
        echo \033[0m
        printf "\n"
        printf "rdi:%16lx rsi:%16lx rdx:%16lx rcx:%16lx\n", $rdi, $rsi, $rdx, $rcx
        printf "rax:%16lx rbx:%16lx rbp:%16lx rsp:%16lx\n", $rax, $rbx, $rbp, $rsp
        printf "r8: %16lx r9: %16lx r10:%16lx r11:%16lx\n", $r8,  $r9,  $r10, $r11
        printf "r12:%16lx r13:%16lx r14:%16lx r15:%16lx\n", $r12, $r13, $r14, $r15
        printf "\n"
        printf "%#018lx %#018lx %#018lx %#018lx\n", *((long*)$sp + 0), *((long*)$sp + 1), *((long*)$sp + 2), *((long*)$sp + 3)
        printf "%#018lx %#018lx %#018lx %#018lx\n", *((long*)$sp + 4), *((long*)$sp + 5), *((long*)$sp + 6), *((long*)$sp + 7)
        printf "%#018lx %#018lx %#018lx %#018lx\n", *((long*)$sp + 8), *((long*)$sp + 9), *((long*)$sp + 10), *((long*)$sp + 11)
        printf "%#018lx %#018lx %#018lx %#018lx\n", *((long*)$sp + 12), *((long*)$sp + 13), *((long*)$sp + 14), *((long*)$sp + 15)
        printf "\n"
    else
        # x86.
        printf "\n"
        echo \033[32m
        x/4i $pc
        echo \033[0m
        printf "\n"
        printf "eax: %8x      ebx: %8x      ecx: %8x      edx: %8x\n", $eax, $ebx, $ecx, $edx
        printf "edi: %8x      esi: %8x      ebp: %8x      esp: %8x\n", $edi, $esi, $ebp, $esp
        printf "\n"
        printf "%#010x %#010x %#010x %#010x\n", *((int*)$sp + 0), *((int*)$sp + 1), *((int*)$sp + 2), *((int*)$sp + 3)
        printf "%#010x %#010x %#010x %#010x\n", *((int*)$sp + 4), *((int*)$sp + 5), *((int*)$sp + 6), *((int*)$sp + 7)
        printf "%#010x %#010x %#010x %#010x\n", *((int*)$sp + 8), *((int*)$sp + 9), *((int*)$sp + 10), *((int*)$sp + 11)
        printf "%#010x %#010x %#010x %#010x\n", *((int*)$sp + 12), *((int*)$sp + 13), *((int*)$sp + 14), *((int*)$sp + 15)
        printf "\n"
    end
end

## ARM
#
#define hook-stop
#    printf "\n"
#    echo \033[32m
#    x/4i $pc
#    echo \033[0m
#    printf "\n"
#    printf "r0: %8lx r1: %8lx r2: %8lx r3: %8lx r4: %8lx r5: %8lx r6: %8lx r7: %8lx\n", $r0, $r1, $r2, $r3, $r4, $r5, $r6, $r7
#    printf "r9: %8lx r10:%8lx r11:%8lx r12:%8lx sp: %8lx lr: %8lx pc: %8lx\n", $r9, $r10, $r11, $r12, $sp, $lr, $pc
#    printf "\n"
#    printf "%#010x %#010x %#010x %#010x\n", *((int*)$sp + 0), *((int*)$sp + 1), *((int*)$sp + 2), *((int*)$sp + 3)
#    printf "%#010x %#010x %#010x %#010x\n", *((int*)$sp + 4), *((int*)$sp + 5), *((int*)$sp + 6), *((int*)$sp + 7)
#    printf "%#010x %#010x %#010x %#010x\n", *((int*)$sp + 8), *((int*)$sp + 9), *((int*)$sp + 10), *((int*)$sp + 11)
#    printf "%#010x %#010x %#010x %#010x\n", *((int*)$sp + 12), *((int*)$sp + 13), *((int*)$sp + 14), *((int*)$sp + 15)
#    printf "\n"
#end
