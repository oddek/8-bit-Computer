	.org #$0006 ; place all this code at address 0006
	ldw xr intx ; load address 001E into register X
	ldw yr inty ; load address 001F into register Y
	add xr ; add x and y reg and put in x
	stw xr #$F0 ; 
	ldi xr #FF ; place value FF into X reg
	ldi yr 99 ; place 99 in decimal into y reg
loop:
	nop
	mov xr yr		
	jmp loop


	.org #$001E
intx:
	.word #05 ; place 5 in address
inty:
	.word 15 ; place 15 in address
char:
	.word 'L' ; place letter L in address
	

