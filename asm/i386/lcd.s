

	.set vram, lcd
	.set buf, scan+512
	.set pal1, scan+768
	.set pal2, scan+896
	.set pal4, scan+1024

	.data
	.balign 4

debug:	.string "%08x\n"



	.text
	.balign 32

	.globl pat_updatepix

	.macro _print arg=0
	pushf
	pusha
	movl \arg, %eax
	pushl %eax
	pushl $debug
	call printf
	addl $8, %esp
	popa
	popf
	.endm

	.macro _patexpand k=0
	movw (%esi,%ecx,2), %ax
	andl $(0x0101<<\k), %eax
	addb $0xff, %al
	sbbb %bl, %bl
	addb $0xff, %ah
	sbbb %bh, %bh
	andl $0x0201, %ebx
	orb %bh, %bl
	movb %bl, patpix+7-\k(%ebp,%ecx,8)
	.endm

	.macro _fastswap k=0
	movl patpix+(16*\k)(%ebp), %eax
	movl patpix+4+(16*\k)(%ebp), %ebx
	movl patpix+8+(16*\k)(%ebp), %ecx
	movl patpix+12+(16*\k)(%ebp), %edx
	bswap %eax
	bswap %ebx
	bswap %ecx
	bswap %edx
	movl %eax, patpix+1024*64+4+(16*\k)(%ebp)
	movl %ebx, patpix+1024*64+(16*\k)(%ebp)
	movl %ecx, patpix+1024*64+12+(16*\k)(%ebp)
	movl %edx, patpix+1024*64+8+(16*\k)(%ebp)
	.endm



pat_updatepix:
	movb anydirty, %al
	testb %al, %al
	jnz .Lupdatepatpix
	ret
	
.Lupdatepatpix:
	pushl %ebp
	pushl %ebx
	pushl %esi
	pushl %edi
	
	movl $895, %edi
.Lmainloop:
	cmpl $511, %edi
	jnz .Lnoskip
	movl $383, %edi
.Lnoskip:	
	movb patdirty(%edi), %al
	testb %al, %al
	jnz .Lpatdirty
	decl %edi
	jnl .Lmainloop
	jmp .Lend
.Lpatdirty:
	movb $0, %al
	movb %al, patdirty(%edi)
	movl %edi, %eax
	movl $vram, %esi
	shll $4, %eax
	addl %eax, %esi

	movl $7, %ecx
	movl %edi, %ebp
	shll $6, %ebp
.Lexpandline:	
	_patexpand 0
	_patexpand 1
	_patexpand 2
	_patexpand 3
	_patexpand 4
	_patexpand 5
	_patexpand 6
	_patexpand 7
	decl %ecx
	jnl .Lexpandline

	_fastswap 0
	_fastswap 1
	_fastswap 2
	_fastswap 3

	movl patpix(%ebp), %eax
	movl patpix+4(%ebp), %ebx
	movl patpix+8(%ebp), %ecx
	movl patpix+12(%ebp), %edx
	movl %eax, patpix+2048*64+56(%ebp)
	movl %ebx, patpix+2048*64+60(%ebp)
	movl %ecx, patpix+2048*64+48(%ebp)
	movl %edx, patpix+2048*64+52(%ebp)
	movl patpix+16(%ebp), %eax
	movl patpix+20(%ebp), %ebx
	movl patpix+24(%ebp), %ecx
	movl patpix+28(%ebp), %edx
	movl %eax, patpix+2048*64+40(%ebp)
	movl %ebx, patpix+2048*64+44(%ebp)
	movl %ecx, patpix+2048*64+32(%ebp)
	movl %edx, patpix+2048*64+36(%ebp)
	movl patpix+32(%ebp), %eax
	movl patpix+36(%ebp), %ebx
	movl patpix+40(%ebp), %ecx
	movl patpix+44(%ebp), %edx
	movl %eax, patpix+2048*64+24(%ebp)
	movl %ebx, patpix+2048*64+28(%ebp)
	movl %ecx, patpix+2048*64+16(%ebp)
	movl %edx, patpix+2048*64+20(%ebp)
	movl patpix+48(%ebp), %eax
	movl patpix+52(%ebp), %ebx
	movl patpix+56(%ebp), %ecx
	movl patpix+60(%ebp), %edx
	movl %eax, patpix+2048*64+8(%ebp)
	movl %ebx, patpix+2048*64+12(%ebp)
	movl %ecx, patpix+2048*64(%ebp)
	movl %edx, patpix+2048*64+4(%ebp)

	movl patpix+1024*64(%ebp), %eax
	movl patpix+1024*64+4(%ebp), %ebx
	movl patpix+1024*64+8(%ebp), %ecx
	movl patpix+1024*64+12(%ebp), %edx
	movl %eax, patpix+3072*64+56(%ebp)
	movl %ebx, patpix+3072*64+60(%ebp)
	movl %ecx, patpix+3072*64+48(%ebp)
	movl %edx, patpix+3072*64+52(%ebp)
	movl patpix+1024*64+16(%ebp), %eax
	movl patpix+1024*64+20(%ebp), %ebx
	movl patpix+1024*64+24(%ebp), %ecx
	movl patpix+1024*64+28(%ebp), %edx
	movl %eax, patpix+3072*64+40(%ebp)
	movl %ebx, patpix+3072*64+44(%ebp)
	movl %ecx, patpix+3072*64+32(%ebp)
	movl %edx, patpix+3072*64+36(%ebp)
	movl patpix+1024*64+32(%ebp), %eax
	movl patpix+1024*64+36(%ebp), %ebx
	movl patpix+1024*64+40(%ebp), %ecx
	movl patpix+1024*64+44(%ebp), %edx
	movl %eax, patpix+3072*64+24(%ebp)
	movl %ebx, patpix+3072*64+28(%ebp)
	movl %ecx, patpix+3072*64+16(%ebp)
	movl %edx, patpix+3072*64+20(%ebp)
	movl patpix+1024*64+48(%ebp), %eax
	movl patpix+1024*64+52(%ebp), %ebx
	movl patpix+1024*64+56(%ebp), %ecx
	movl patpix+1024*64+60(%ebp), %edx
	movl %eax, patpix+3072*64+8(%ebp)
	movl %ebx, patpix+3072*64+12(%ebp)
	movl %ecx, patpix+3072*64(%ebp)
	movl %edx, patpix+3072*64+4(%ebp)

	decl %edi
	jnl .Lmainloop
.Lend:
	movb $0, %al
	movb %al, anydirty
	popl %edi
	popl %esi
	popl %ebx
	popl %ebp
	ret


	.globl refresh_1
refresh_1:
	pushl %ebx
	pushl %esi
	pushl %edi
	movl 16(%esp), %edi
	movl $-40, %esi
	xorl %eax, %eax
	xorl %ebx, %ebx
	addl $160, %edi
	
	movl buf+160(,%esi,4), %edx
	movb %dl, %al
	movb %dh, %bl
.Lrefresh_1:
	bswap %edx
	movb pal1(%eax), %cl
	movb %dh, %al
	movb pal1(%ebx), %ch
	movb %dl, %bl
	bswap %ecx
	movl buf+164(,%esi,4), %edx
	movb pal1(%eax), %ch
	movb %dl, %al
	movb pal1(%ebx), %cl
	movb %dh, %bl
	bswap %ecx
	movl %ecx, (%edi,%esi,4)
	incl %esi
	jnz .Lrefresh_1
	popl %edi
	popl %esi
	popl %ebx
	ret


	.globl refresh_2
refresh_2:
	pushl %ebx
	pushl %esi
	pushl %edi
	movl 16(%esp), %edi
	movl $-80, %esi
	xorl %eax, %eax
	xorl %ebx, %ebx
	movl buf+160(,%esi,2), %edx
	movb %dh, %bl
	movb %dl, %al
.Lrefresh_2:
	bswap %edx
	movw pal2(,%ebx,2), %cx
	movb %dl, %bl
	roll $16, %ecx
	movw pal2(,%eax,2), %cx
	movb %dh, %al
	movl %ecx, 320(%edi,%esi,4)
	movl buf+164(,%esi,2), %edx
	movw pal2(,%ebx,2), %cx
	movb %dh, %bl
	roll $16, %ecx
	movw pal2(,%eax,2), %cx
	movb %dl, %al
	movl %ecx, 324(%edi,%esi,4)
	addl $2, %esi
	jnz .Lrefresh_2
	popl %edi
	popl %esi
	popl %ebx
	ret





	.globl refresh_4
refresh_4:
	pushl %ebp
	pushl %ebx
	pushl %esi
	pushl %edi
	movl 20(%esp), %edi
	movl $-160, %esi
	xorl %eax, %eax
	xorl %ebx, %ebx
	movl buf+160(%esi), %edx
	movb %dl, %al
	movb %dh, %bl
.Lrefresh_4:	
	bswap %edx
	movl pal4(,%eax,4),%ecx
	movl pal4(,%ebx,4),%ebp
	movb %dh, %al
	movb %dl, %bl
	movl %ecx, 640(%edi,%esi,4)
	movl %ebp, 644(%edi,%esi,4)
	movl buf+164(%esi), %edx
	movl pal4(,%eax,4),%ecx
	movl pal4(,%ebx,4),%ebp
	movb %dl, %al
	movb %dh, %bl
	movl %ecx, 648(%edi,%esi,4)
	movl %ebp, 652(%edi,%esi,4)
	addl $4, %esi
	jnz .Lrefresh_4
	popl %edi
	popl %esi
	popl %ebx
	popl %ebp
	ret
	



	.globl blendcpy8
blendcpy8:
	pushl %ebx
	movl 16(%esp), %ecx
	movb %cl, %ch
	movl 12(%esp), %eax
	movl %ecx, %ebx
	roll $16, %ecx
	movl 8(%esp), %edx
	orl %ebx, %ecx
	movl (%eax), %ebx
	orl %ecx, %ebx
	movl 4(%eax), %eax
	orl %ecx, %eax
	movl %ebx, (%edx)
	movl %eax, 4(%edx)
	popl %ebx
	ret

	















