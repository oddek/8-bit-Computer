
; set cursor stuff:

	ldi xr #0E ; Display on, cursor on, blink off : 00001110 
	stw xr #FE ; store to port B

	ldi xr #0 ; clear RS/RW/E bits
	stw xr #FF ; store to port A  

	ldw xr enable ; enable write to lcd 
	stw xr #FF ; store to port A  
	 
	ldi xr #0 ; clear RS/RW/E bits
	stw xr #FF ; store to port A  


; entry mode set

	ldi xr #06 ; Increment and shift curosr, don't shift display, 00000110
	stw xr #FE ; store to port B

	ldi xr #0 ; clear RS/RW/E bits
	stw xr #FF ; store to port A  

	ldw xr enable ; enable write to lcd 
	stw xr #FF ; store to port A  
	 
	ldi xr #0 ; clear RS/RW/E bits
	stw xr #FF ; store to port A  

; write Hello,world to lcd
	ldw xr charH ; 
	stw xr #FE ; store to port B
	jmp writeChar

	ldw xr chari ;
	stw xr #FE ; store to port B
	jmp writeChar

	ldw xr char, ;
	stw xr #FE ; store to port B
	jmp writeChar

	ldw xr charW ;
	stw xr #FE ; store to port B
	jmp writeChar

	ldw xr charo ;
	stw xr #FE ; store to port B
	jmp writeChar

	ldw xr charr ;
	stw xr #FE ; store to port B
	jmp writeChar

	ldw xr charl ;
	stw xr #FE ; store to port B
	jmp writeChar

	ldw xr chard 
	stw xr #FE ; store to port B
	jmp writeChar

	ldw xr char! 
	stw xr #FE ; store to port B
	jmp writeChar

loop:
	jmp loop

writeChar:
	ldw xr rs ; set register select
	stw xr #FF ; store to port A  
	ldw xr enrs ; enable write to lcd 
	stw xr #FF ; store to port A  
	 
	ldw xr rs ; clear RS/RW/E bits
	stw xr #FF ; store to port A  

	ret




	.org #$70 ; place following code at address 0x1E
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
charH:
	.word 'H'
chari:
	.word 'i'
charl:
	.word 'l'
char,:
	.word ','
charW:
	.word 'W'
charo:
	.word 'o'
charr:
	.word 'r'
chard:
	.word 'd'
char!:
	.word '!'
