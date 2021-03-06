.text
.code64

.SET USER_SS, 0x20 | 0x3
.SET USER_CS, 0x18 | 0x3

.global switchToUserMode
.type switchToUserMode, %function
switchToUserMode: // RIP = %rdi, RSP = %rsi, RDI = %rdx, RSI = %rcx, FS = %r8
	// Data segmentation registers
	mov $USER_SS, %ax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %fs
	mov %ax, %gs
	mov %rsi, %rsp

	push $exitHelper
	mov %rsp, %rbp

	mov %rsp, %rax

	// Data segmentation SS
	push $USER_SS

	// Stack pointer
	push %rax

	// FLAGS, Enabling interrupt
	pushfq
	pop %rax
	orq $0x200, %rax
	push %rax

	// Code segmentation register
	push $USER_CS

	// Instruction pointer
	push %rdi

	// Argc
	mov %rdx, %rdi
	// Argv
	mov %rcx, %rsi

	// Setup FSBASE
	mov %r8, %rax;
	mov %rax, %rdx;
	shr $32, %rdx
	mov $0xC0000100, %ecx
	wrmsr

	mov $0, %rax
	mov %rax, %rbx
	mov %rax, %rcx
	mov %rax, %rdx
	mov %rax, %rbp
	mov %rax, %r8
	mov %rax, %r9
	mov %rax, %r10
	mov %rax, %r11
	mov %rax, %r12
	mov %rax, %r13
	mov %rax, %r14
	mov %rax, %r15

	iretq

.size switchToUserMode, .-switchToUserMode


.global getRIP
.type getRIP, %function
getRIP:
	mov (%rsp), %rax
	ret
.size getRIP, .-getRIP

.global fpuEnable
.type fpuEnable, %function
fpuEnable:
	clts
	mov %cr0, %rcx
	or $0x8, %rcx
	movq %rcx, %cr0
	ret
.size fpuEnable, .-fpuEnable

.global fpuDisable
.type fpuDisable, %function
fpuDisable:
	mov %cr4, %rcx
	or $600, %rcx
	movq %rcx, %cr4
	ret
.size fpuDisable, .-fpuDisable

.global cloneHelperKernelTask
.type cloneHelperKernelTask, %function
cloneHelperKernelTask:
	pop %r15
	pop %r14
	pop %r13
	pop %r12
	pop %r11
	pop %r10
	pop %r9
	pop %r8

	pop %rbp
	pop %rdi
	pop %rsi
	pop %rdx
	pop %rcx
	pop %rbx
	pop %rax

	add $0x10, %rsp

	iretq
.size cloneHelperKernelTask, .-cloneHelperKernelTask

.global cloneHelperFork
.type cloneHelperFork, %function
cloneHelperFork:
	pop %r15
	pop %r14
	pop %r13
	pop %r12
	pop %r11
	pop %r10
	pop %r9
	pop %r8
	pop %rbp
	pop %rdi
	pop %rsi
	pop %rdx
	pop %rcx
	pop %rbx
	pop %rax

	add $(8 * 7), %rsp

	// userstack
	pop %rsp

	swapgs
	sysretq
.size cloneHelperFork, .-cloneHelperFork

.global exitHelper
.type exitHelper, %function
exitHelper:
	mov %rax, %rdi
	mov $0, %rax
	int $0x80
.size exitHelper, .-exitHelper

.global getCS
.type getCS, %function
getCS:
	mov %cs, %rax
	ret
.size getCS, .-getCS
