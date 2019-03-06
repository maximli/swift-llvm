; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s

; Select of constants: control flow / conditional moves can always be replaced by logic+math (but may not be worth it?).
; Test the zeroext/signext variants of each pattern to see if that makes a difference.

; select Cond, 0, 1 --> zext (!Cond)

define i32 @select_0_or_1(i1 %cond) {
; CHECK-LABEL: select_0_or_1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    notb %dil
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    andl $1, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 0, i32 1
  ret i32 %sel
}

define i32 @select_0_or_1_zeroext(i1 zeroext %cond) {
; CHECK-LABEL: select_0_or_1_zeroext:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorb $1, %dil
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 0, i32 1
  ret i32 %sel
}

define i32 @select_0_or_1_signext(i1 signext %cond) {
; CHECK-LABEL: select_0_or_1_signext:
; CHECK:       # %bb.0:
; CHECK-NEXT:    notb %dil
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    andl $1, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 0, i32 1
  ret i32 %sel
}

; select Cond, 1, 0 --> zext (Cond)

define i32 @select_1_or_0(i1 %cond) {
; CHECK-LABEL: select_1_or_0:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    andl $1, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 1, i32 0
  ret i32 %sel
}

define i32 @select_1_or_0_zeroext(i1 zeroext %cond) {
; CHECK-LABEL: select_1_or_0_zeroext:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 1, i32 0
  ret i32 %sel
}

define i32 @select_1_or_0_signext(i1 signext %cond) {
; CHECK-LABEL: select_1_or_0_signext:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    andl $1, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 1, i32 0
  ret i32 %sel
}

; select Cond, 0, -1 --> sext (!Cond)

define i32 @select_0_or_neg1(i1 %cond) {
; CHECK-LABEL: select_0_or_neg1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    # kill: def $edi killed $edi def $rdi
; CHECK-NEXT:    andl $1, %edi
; CHECK-NEXT:    leal -1(%rdi), %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 0, i32 -1
  ret i32 %sel
}

define i32 @select_0_or_neg1_zeroext(i1 zeroext %cond) {
; CHECK-LABEL: select_0_or_neg1_zeroext:
; CHECK:       # %bb.0:
; CHECK-NEXT:    # kill: def $edi killed $edi def $rdi
; CHECK-NEXT:    leal -1(%rdi), %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 0, i32 -1
  ret i32 %sel
}

define i32 @select_0_or_neg1_signext(i1 signext %cond) {
; CHECK-LABEL: select_0_or_neg1_signext:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    notl %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 0, i32 -1
  ret i32 %sel
}

; select Cond, -1, 0 --> sext (Cond)

define i32 @select_neg1_or_0(i1 %cond) {
; CHECK-LABEL: select_neg1_or_0:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    andl $1, %eax
; CHECK-NEXT:    negl %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 -1, i32 0
  ret i32 %sel
}

define i32 @select_neg1_or_0_zeroext(i1 zeroext %cond) {
; CHECK-LABEL: select_neg1_or_0_zeroext:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    negl %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 -1, i32 0
  ret i32 %sel
}

define i32 @select_neg1_or_0_signext(i1 signext %cond) {
; CHECK-LABEL: select_neg1_or_0_signext:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 -1, i32 0
  ret i32 %sel
}

; select Cond, C+1, C --> add (zext Cond), C

define i32 @select_Cplus1_C(i1 %cond) {
; CHECK-LABEL: select_Cplus1_C:
; CHECK:       # %bb.0:
; CHECK-NEXT:    # kill: def $edi killed $edi def $rdi
; CHECK-NEXT:    andl $1, %edi
; CHECK-NEXT:    leal 41(%rdi), %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 42, i32 41
  ret i32 %sel
}

define i32 @select_Cplus1_C_zeroext(i1 zeroext %cond) {
; CHECK-LABEL: select_Cplus1_C_zeroext:
; CHECK:       # %bb.0:
; CHECK-NEXT:    # kill: def $edi killed $edi def $rdi
; CHECK-NEXT:    leal 41(%rdi), %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 42, i32 41
  ret i32 %sel
}

define i32 @select_Cplus1_C_signext(i1 signext %cond) {
; CHECK-LABEL: select_Cplus1_C_signext:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl $41, %eax
; CHECK-NEXT:    subl %edi, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 42, i32 41
  ret i32 %sel
}

; select Cond, C, C+1 --> add (sext Cond), C

define i32 @select_C_Cplus1(i1 %cond) {
; CHECK-LABEL: select_C_Cplus1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    andl $1, %edi
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    subl %edi, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 41, i32 42
  ret i32 %sel
}

define i32 @select_C_Cplus1_zeroext(i1 zeroext %cond) {
; CHECK-LABEL: select_C_Cplus1_zeroext:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    subl %edi, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 41, i32 42
  ret i32 %sel
}

define i32 @select_C_Cplus1_signext(i1 signext %cond) {
; CHECK-LABEL: select_C_Cplus1_signext:
; CHECK:       # %bb.0:
; CHECK-NEXT:    # kill: def $edi killed $edi def $rdi
; CHECK-NEXT:    leal 42(%rdi), %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 41, i32 42
  ret i32 %sel
}

; If the constants differ by a small multiplier, use LEA.
; select Cond, C1, C2 --> add (mul (zext Cond), C1-C2), C2 --> LEA C2(Cond * (C1-C2))

define i32 @select_lea_2(i1 zeroext %cond) {
; CHECK-LABEL: select_lea_2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorb $1, %dil
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    leal -1(%rax,%rax), %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 -1, i32 1
  ret i32 %sel
}

define i64 @select_lea_3(i1 zeroext %cond) {
; CHECK-LABEL: select_lea_3:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorb $1, %dil
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    leaq -2(%rax,%rax,2), %rax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i64 -2, i64 1
  ret i64 %sel
}

define i32 @select_lea_5(i1 zeroext %cond) {
; CHECK-LABEL: select_lea_5:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorb $1, %dil
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    leal -2(%rax,%rax,4), %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 -2, i32 3
  ret i32 %sel
}

define i64 @select_lea_9(i1 zeroext %cond) {
; CHECK-LABEL: select_lea_9:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorb $1, %dil
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    leaq -7(%rax,%rax,8), %rax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i64 -7, i64 2
  ret i64 %sel
}

; Should this be 'sbb x,x' or 'sbb 0,x' with simpler LEA or add?

define i64 @sel_1_2(i64 %x, i64 %y) {
; CHECK-LABEL: sel_1_2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cmpq $42, %rdi
; CHECK-NEXT:    sbbq $0, %rsi
; CHECK-NEXT:    leaq 2(%rsi), %rax
; CHECK-NEXT:    retq
  %cmp = icmp ult i64 %x, 42
  %sel = select i1 %cmp, i64 1, i64 2
  %sub = add i64 %sel, %y
  ret i64 %sub
}

; No LEA with 8-bit, but this shouldn't need branches or cmov.

define i8 @sel_1_neg1(i32 %x) {
; CHECK-LABEL: sel_1_neg1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cmpl $42, %edi
; CHECK-NEXT:    setg %al
; CHECK-NEXT:    shlb $2, %al
; CHECK-NEXT:    decb %al
; CHECK-NEXT:    retq
  %cmp = icmp sgt i32 %x, 42
  %sel = select i1 %cmp, i8 3, i8 -1
  ret i8 %sel
}

; We get an LEA for 16-bit because we ignore the high-bits.

define i16 @sel_neg1_1(i32 %x) {
; CHECK-LABEL: sel_neg1_1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    cmpl $43, %edi
; CHECK-NEXT:    setl %al
; CHECK-NEXT:    leal -1(,%rax,4), %eax
; CHECK-NEXT:    # kill: def $ax killed $ax killed $eax
; CHECK-NEXT:    retq
  %cmp = icmp sgt i32 %x, 42
  %sel = select i1 %cmp, i16 -1, i16 3
  ret i16 %sel
}

; If the comparison is available, the predicate can be inverted.

define i32 @sel_1_neg1_32(i32 %x) {
; CHECK-LABEL: sel_1_neg1_32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    cmpl $42, %edi
; CHECK-NEXT:    setg %al
; CHECK-NEXT:    leal -1(%rax,%rax,8), %eax
; CHECK-NEXT:    retq
  %cmp = icmp sgt i32 %x, 42
  %sel = select i1 %cmp, i32 8, i32 -1
  ret i32 %sel
}

define i32 @sel_neg1_1_32(i32 %x) {
; CHECK-LABEL: sel_neg1_1_32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    cmpl $43, %edi
; CHECK-NEXT:    setl %al
; CHECK-NEXT:    leal -7(%rax,%rax,8), %eax
; CHECK-NEXT:    retq
  %cmp = icmp sgt i32 %x, 42
  %sel = select i1 %cmp, i32 -7, i32 2
  ret i32 %sel
}


; If the constants differ by a large power-of-2, that can be a shift of the difference plus the smaller constant.
; select Cond, C1, C2 --> add (mul (zext Cond), C1-C2), C2

define i8 @select_pow2_diff(i1 zeroext %cond) {
; CHECK-LABEL: select_pow2_diff:
; CHECK:       # %bb.0:
; CHECK-NEXT:    # kill: def $edi killed $edi def $rdi
; CHECK-NEXT:    shlb $4, %dil
; CHECK-NEXT:    leal 3(%rdi), %eax
; CHECK-NEXT:    # kill: def $al killed $al killed $eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i8 19, i8 3
  ret i8 %sel
}

define i16 @select_pow2_diff_invert(i1 zeroext %cond) {
; CHECK-LABEL: select_pow2_diff_invert:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorb $1, %dil
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    shll $6, %eax
; CHECK-NEXT:    orl $7, %eax
; CHECK-NEXT:    # kill: def $ax killed $ax killed $eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i16 7, i16 71
  ret i16 %sel
}

define i32 @select_pow2_diff_neg(i1 zeroext %cond) {
; CHECK-LABEL: select_pow2_diff_neg:
; CHECK:       # %bb.0:
; CHECK-NEXT:    shlb $4, %dil
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    orl $-25, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 -9, i32 -25
  ret i32 %sel
}

define i64 @select_pow2_diff_neg_invert(i1 zeroext %cond) {
; CHECK-LABEL: select_pow2_diff_neg_invert:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorb $1, %dil
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    shlq $7, %rax
; CHECK-NEXT:    addq $-99, %rax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i64 -99, i64 29
  ret i64 %sel
}

; This doesn't need a branch, but don't do the wrong thing if subtraction of the constants overflows.

define i8 @sel_67_neg125(i32 %x) {
; CHECK-LABEL: sel_67_neg125:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cmpl $42, %edi
; CHECK-NEXT:    movb $67, %al
; CHECK-NEXT:    jg .LBB31_2
; CHECK-NEXT:  # %bb.1:
; CHECK-NEXT:    movb $-125, %al
; CHECK-NEXT:  .LBB31_2:
; CHECK-NEXT:    retq
  %cmp = icmp sgt i32 %x, 42
  %sel = select i1 %cmp, i8 67, i8 -125
  ret i8 %sel
}


; In general, select of 2 constants could be:
; select Cond, C1, C2 --> add (mul (zext Cond), C1-C2), C2 --> add (and (sext Cond), C1-C2), C2

define i32 @select_C1_C2(i1 %cond) {
; CHECK-LABEL: select_C1_C2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    movl $421, %ecx # imm = 0x1A5
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    cmovnel %ecx, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 421, i32 42
  ret i32 %sel
}

define i32 @select_C1_C2_zeroext(i1 zeroext %cond) {
; CHECK-LABEL: select_C1_C2_zeroext:
; CHECK:       # %bb.0:
; CHECK-NEXT:    testl %edi, %edi
; CHECK-NEXT:    movl $421, %ecx # imm = 0x1A5
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    cmovnel %ecx, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 421, i32 42
  ret i32 %sel
}

define i32 @select_C1_C2_signext(i1 signext %cond) {
; CHECK-LABEL: select_C1_C2_signext:
; CHECK:       # %bb.0:
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    movl $421, %ecx # imm = 0x1A5
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    cmovnel %ecx, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 421, i32 42
  ret i32 %sel
}

; select (x == 2), 2, (x + 1) --> select (x == 2), x, (x + 1)

define i64 @select_2_or_inc(i64 %x) {
; CHECK-LABEL: select_2_or_inc:
; CHECK:       # %bb.0:
; CHECK-NEXT:    leaq 1(%rdi), %rax
; CHECK-NEXT:    cmpq $2, %rdi
; CHECK-NEXT:    cmoveq %rdi, %rax
; CHECK-NEXT:    retq
  %cmp = icmp eq i64 %x, 2
  %add = add i64 %x, 1
  %retval.0 = select i1 %cmp, i64 2, i64 %add
  ret i64 %retval.0
}

define <4 x i32> @sel_constants_add_constant_vec(i1 %cond) {
; CHECK-LABEL: sel_constants_add_constant_vec:
; CHECK:       # %bb.0:
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    jne .LBB36_1
; CHECK-NEXT:  # %bb.2:
; CHECK-NEXT:    movaps {{.*#+}} xmm0 = [12,13,14,15]
; CHECK-NEXT:    retq
; CHECK-NEXT:  .LBB36_1:
; CHECK-NEXT:    movaps {{.*#+}} xmm0 = [4294967293,14,4,4]
; CHECK-NEXT:    retq
  %sel = select i1 %cond, <4 x i32> <i32 -4, i32 12, i32 1, i32 0>, <4 x i32> <i32 11, i32 11, i32 11, i32 11>
  %bo = add <4 x i32> %sel, <i32 1, i32 2, i32 3, i32 4>
  ret <4 x i32> %bo
}

define <2 x double> @sel_constants_fmul_constant_vec(i1 %cond) {
; CHECK-LABEL: sel_constants_fmul_constant_vec:
; CHECK:       # %bb.0:
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    jne .LBB37_1
; CHECK-NEXT:  # %bb.2:
; CHECK-NEXT:    movaps {{.*#+}} xmm0 = [1.1883E+2,3.4539999999999999E+1]
; CHECK-NEXT:    retq
; CHECK-NEXT:  .LBB37_1:
; CHECK-NEXT:    movaps {{.*#+}} xmm0 = [-2.0399999999999999E+1,3.768E+1]
; CHECK-NEXT:    retq
  %sel = select i1 %cond, <2 x double> <double -4.0, double 12.0>, <2 x double> <double 23.3, double 11.0>
  %bo = fmul <2 x double> %sel, <double 5.1, double 3.14>
  ret <2 x double> %bo
}

; 4294967297 = 0x100000001.
; This becomes an opaque constant via ConstantHoisting, so we don't fold it into the select.

define i64 @opaque_constant(i1 %cond, i64 %x) {
; CHECK-LABEL: opaque_constant:
; CHECK:       # %bb.0:
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    movq $-4, %rcx
; CHECK-NEXT:    movl $23, %eax
; CHECK-NEXT:    cmovneq %rcx, %rax
; CHECK-NEXT:    movabsq $4294967297, %rcx # imm = 0x100000001
; CHECK-NEXT:    andq %rcx, %rax
; CHECK-NEXT:    xorl %edx, %edx
; CHECK-NEXT:    cmpq %rcx, %rsi
; CHECK-NEXT:    sete %dl
; CHECK-NEXT:    subq %rdx, %rax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i64 -4, i64 23
  %bo = and i64 %sel, 4294967297
  %cmp = icmp eq i64 %x, 4294967297
  %sext = sext i1 %cmp to i64
  %add = add i64 %bo, %sext
  ret i64 %add
}

define float @select_undef_fp(float %x) {
; CHECK-LABEL: select_undef_fp:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-NEXT:    retq
  %f = select i1 undef, float 4.0, float %x
  ret float %f
}

