	.org #$02 ; place following code at address 0x02
	ldw xr inta ; load contents of address 001E into register X
	ldw yr intb ; load contents of address 001F into register Y
	add xr ;  add contents of x and y register. Place result in x register
	stw xr #$F0 ; store the contents of x register at address 0xF0
loop:
	nop ; do nothing
	jmp loop ; jump to label 'loop'


	.org #$1E ; place following code at address 0x1E
inta:
	.word #05 ; place literal 0x5 at this address
intb:
	.word 15 ; place literal 15 at this address
