	.org $0005 ; place all this code at address 0005
	ldw $x intx ; load address 001E into register X
	ldw $y inty ; load address 001F into register Y
	add $x $x $y ; 
	stw $x $FFF0 ; 


	.org $001E
intx:
	.word 0005 ; place 5 in address
inty:
	.word 0015 ; place 15 in address

	

