	.org $0005 ; place all this code at address 0005
	ldw xr intx ; load address 001E into register X
	ldw yr inty ; load address 001F into register Y
	add xr xr yr ; 
	stw xr &FFF0 ; 


	.org $001E
intx:
	.word #0005 ; place 5 in address
inty:
	.word #0015 ; place 15 in address

	

