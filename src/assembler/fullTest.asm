	;.org #$0002 ; place all this code at address 0006
	ldw xr intx ; load address 001E into register X
	ldw yr inty ; load address 001F into register Y
	addu xr
	subu yr
	and xr ; add x and y reg and put in x
	or yr ;
	not yr
	xor yr
	xnor yr
	sll yr
	srl xr
	mul
	div
	inl #FF
	ini #1
	stw xr #$F0 ; 
	ldi xr #FF ; place value FF into X reg
	ldi yr 99 ; place 99 in decimal into y reg
	subu xr ; substitute
	beq func ; jump to function
	bgt func 
	bge func
loop:
	nop
	mov xr yr		
	jmp loop


	.org #$004E
intx:
	.word #05 ; place 5 in address
inty:
	.word 15 ; place 15 in address
char:
	.word 'L' ; place letter L in address
	

func:
	psh xr
	ldw xr intx
	pul xr
	ret
