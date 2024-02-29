.globl _start
.section .init
.extern __bootstrapper

_start:
	call get_pc
pivot:
	sub $8,%esp
	lea _DYNAMIC-pivot(%eax),%edi
	push %edi
	lea 0-pivot(%eax),%edi
	push %edi
	call __bootstrapper
	int3
get_pc:
	mov (%esp),%eax
	ret
