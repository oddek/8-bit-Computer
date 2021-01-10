; set cursor stuff:
	ldi xr #0E ; Display on, cursor on, blink off : 00001110 
	jmp writeSet

; entry mode set
	ldi xr #06 ; Increment and shift curosr, don't shift display, 00000110
	jmp writeSet

; write fib 
	ldi xr 'F' ; print F
	jmp writeChar
	ldi xr 'i' ; print i 
	jmp writeChar
	ldi xr 'b' ; print b
	jmp writeChar

; load initial values and print them
	ldi xr #0 ; load 0 
	stw xr #90 ; store in addr1
	ldw yr ascii
	addu xr ; add ascii offset
	jmp writeChar ; print 0

	ldw xr sep ; load and print comma
	jmp writeChar

	ldi xr #1 ; load 1
	stw xr #91 
	ldw yr ascii
	addu xr ; add ascii offset
	jmp writeChar ; print 1
	
	ldw xr sep ; load and print comma
	jmp writeChar

fib:
	ldw xr #$90 ; load values, add and store result
	ldw yr #$91
	stw yr #$90
	addu xr
	stw xr #$91

	ldi yr #9 ; Check if val is bigger than 9, if so exit
	bgt loop 

	ldw yr ascii ; Add ascii offset
	addu xr 

	jmp writeChar

	ldw xr sep ; load and print comma
	jmp writeChar

	jmp fib

writeSet:
	stw xr #FE ; store to port B
	ldi xr #0 ; clear RS/RW/E bits
	stw xr #FF ; store to port A  
	ldw xr enable ; enable write to lcd 
	stw xr #FF ; store to port A  
	ldi xr #0 ; clear RS/RW/E bits
	stw xr #FF ; store to port A  

	ret


writeChar:
	stw xr #FE ; store to port B
	ldw xr rs ; set register select
	stw xr #FF ; store to port A  
	ldw xr enrs ; enable write to lcd 
	stw xr #FF ; store to port A  
	ldw xr rs ; clear RS/RW/E bits
	stw xr #FF ; store to port A  

	ret


loop:
	jmp writeSet ;
	jmp loop ; loop forever


	.org #$78 ; place following code at address 0x1E
porta:
	.word #FF ; place literal 0x5 at this address
portb:
	.word #FE ; place literal 15 at this address
enable:
	.word #80 ; store 10000000
rw:
	.word #40 ; store 01000000
rs:
	.word #20 ; store 00100000
enrs:
	.word #A0
ascii:
	.word #30 ;
sep:
	.word ',' 
