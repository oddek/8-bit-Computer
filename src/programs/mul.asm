	.org #$02 ; place following code at address 0x02
	ldw xr inta ; load contents of address 001E into register X
	ldw yr intb ; load contents of address 001F into register Y
	mul ; multiplies x and y. Places result in hi and lo reg.  
	stw hi #$F0 ; store upper bits of result at address 0xF0
	stw lo #$F1 ; store lower bits of result at address 0xF1
loop:
	nop ; do nothing
	jmp loop ; jump to label 'loop'


	.org #$1E ; place following code at address 0x1E
inta:
	.word #05 ; place literal 0x5 at this address
intb:
	.word 15 ; place literal 15 at this address
