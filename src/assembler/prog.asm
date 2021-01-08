	.org #$02 ; place following code at address 0x02
	ldw xr intx ; load address 001E into register X
	ldw yr inty ; load address 001F into register Y
	add xr ;  add contents of x and y register. Place result in x register
	stw xr #$F0 ; store the contents of x register at address 0xF0
	; ldi xr #FF ; place value FF into X reg
	; ldi yr 99 ; place 99 in decimal into y reg
loop:
	nop ; do nothing
	; mov xr yr	; move contents of y register into x register
	jmp loop ; jump to label 'loop'


	.org #$1E ; place following code at address 0x1E
intx:
	.word #05 ; place 5 at this address
inty:
	.word 15 ; place 15 at this address
char:
	.word 'L' ; place letter L at this address
	

