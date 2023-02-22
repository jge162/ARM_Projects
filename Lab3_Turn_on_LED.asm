; When SW1 is pressed, RED LED turns on

; Built-in LED1 connected to P1.0
; Negative logic built-in button 1 connected to P1.1

			.thumb

			.text					; Following put in ROM
; Port 1 Registers
P4IN        .word    0x40004C21        ; Port 5 Input
P4OUT       .word    0x40004C23        ; Port 5 Output
P4DIR       .word    0x40004C25        ; Port 5 Direction
P4REN       .word    0x40004C27        ; Port 5 Resistor Enable
P4SEL0      .word    0x40004C2B        ; Port 5 Select 0
P4SEL1      .word    0x40004C2D        ; Port 5 Select 1

P5IN        .word    0x40004C40        ; Port 5 Input
P5OUT       .word    0x40004C42        ; Port 5 Output
P5DIR       .word    0x40004C44        ; Port 5 Direction
P5SEL0      .word    0x40004C4A        ; Port 5 Select 0
P5SEL1      .word    0x40004C4C        ; Port 5 Select 1
P5REN		.word    0x40004C06

P1IN    	.word	0x40004C00		; Port 1 Input
P1OUT   	.word	0x40004C02		; Port 1 Output
P1DIR   	.word	0x40004C04		; Port 1 Direction
P1REN   	.word	0x40004C06		; Port 1 Resistor Enable
P1DS    	.word	0x40004C08		; Port 1 Drive Strength
P1SEL0  	.word	0x40004C0A		; Port 1 Select 0
P1SEL1  	.word	0x40004C0C		; Port 1 Select 1

			.global asm_main
			.thumbfunc asm_main

asm_main:	.asmfunc				; Main
	BL   	GPIO_Init				; Call GPIO_Init to initialize ports
	LDR  	R1, P1OUT				; Load P1OUT (output register for port 1) into R1 (Red LED)
	LDR 	R2, P1IN				; Load P1IN (input register for port 1) into R2 (SW1 input)

loop:
	BL TURN_ON_LED					; Call TURN_ON_LED to turn on the Red LED when SW1 is pressed
	B loop							; Loop continuously

TURN_ON_LED:
	PUSH	{R3}					; Save context
	MOV		R3, #0x05				; Set pin 1.0 to 1 to turn on Red LED
	STRB	R3, [R1]				; Store value in P1OUT (output register for port 1)
	POP		{R3}					; Restore context
	B		loop					; Return to loop

TURN_OFF_LED:
	PUSH	{R3}					; Save context
	MOV		R3, #0x10				; Set P1.0 output to 0 to turn off the LED
	STRB	R3, [R1]
	POP		{R3}					; Restore context
	B		loop				; Branch to the loop label
			.endasmfunc

GPIO_Init:	.asmfunc				; Initialization of ports
	PUSH	{R0-R1}					; Save context

	; Initialize P1 ports
	LDR 	R1, P4SEL0
	LDRB	R0, [R1]
	BIC		R0, R0, #0x05          ; Configure pins as GPIO
	STRB	R0, [R1]

	LDR		R1, P4SEL1
	LDRB	R0, [R1]
	BIC		R0, R0, #0x05           ; Configure pins as GPIO
	STRB 	R0, [R1]

	; Make P1.0 output and P1.1 input
	LDR		R1, P4DIR
	LDRB	R0, [R1]
	BIC		R0, R0, #0x05           ; Set P1.1 as input (0)
	ORR		R0, R0, #0x01           ; Set P1.0 as output (1)
	STRB	R0, [R1]
;--------------------------------------------------------------------------
	; Enable pull-up resistor on P1.1
    LDR  	R1, P4REN
    LDRB 	R0, [R1]
    ORR  	R0, R0, #0x05          ; Enable pull resistor
    STRB 	R0, [R1]

    ; Set P1.0 output high to turn on LED
    LDR  	R1, P4OUT
    LDRB 	R0, [R1]
    ORR  	R0, R0, #0x05           ; Enable pull-up resistor
    POP		{R0-R1}					; Restore context

;--------------------------------------------------------------------------
    ; Make P1.0 output and P1.4 input
	LDR		R1, P5DIR
	LDRB	R0, [R1]
	BIC		R0, R0, #0x10           ; Set P1.4 as input (0)
	ORR		R0, R0, #0x01           ; Set P1.0 as output (1)
	STRB	R0, [R1]

	; Enable pull-up resistor on P1.4
    LDR  	R1, P5REN
    LDRB 	R0, [R1]
    ORR  	R0, R0, #0x10           ; Enable pull resistor
    STRB 	R0, [R1]

    ; Set P1.0 output high to turn on LED
    LDR  	R1, P5OUT
    LDRB 	R0, [R1]
    ORR  	R0, R0, #0x10           ; Enable pull-up resistor
    POP		{R0-R1}	    ; Restore context

;--------------------------------------------------------------------------
			.endasmfunc

;GPIO_Input:	.asmfunc

	; Get P1.1 and P1.4 inputs and return via R0 and R7 respectively
	LDRB	R0, [R2]
