; When SW1 is pressed, RED LED turns on

; Built-in LED1 connected to P4.0
; Negative logic built-in button 1 connected to P5.4

.thumb

.text ; Following put in ROM
; Port 5 Registers
P5IN        .word    0x40004C40        ; Port 5 Input
P5OUT       .word    0x40004C42        ; Port 5 Output
P5DIR       .word    0x40004C44        ; Port 5 Direction
P5REN       .word    0x40004C46        ; Port 5 Resistor Enable
P5SEL0      .word    0x40004C4A        ; Port 5 Select 0
P5SEL1      .word    0x40004C4C        ; Port 5 Select 1

; Port 4 Registers
P4IN        .word    0x40004C21        ; Port 5 Input
P4OUT       .word    0x40004C23        ; Port 5 Output
P4DIR       .word    0x40004C25        ; Port 5 Direction
P4REN       .word    0x40004C27        ; Port 5 Resistor Enable
P4SEL0      .word    0x40004C2B        ; Port 5 Select 0
P4SEL1      .word    0x40004C2D        ; Port 5 Select 1

;***************Constants**************************
DELAYIS62MS	    .equ	0x924A     ; 62 ms/0x924A is '37450' in decimal total cycles are 180k...
;DELAYIS62MS	.equ    0xFFFF ; 100 ms testing...
;DELAYIS62MS	.equ	0x1    ; For debugging only
;**************************************************
		.global asm_main
		.thumbfunc asm_main

asm_main: .asmfunc             ; Main

	BL   EXTERNAL_LED_Init ; Init for P4.0
	BL   GPIO_Init			   ; Init for P5.4
	LDR  R1, P4OUT             ; R0 = Red LED
	LDR  R2, P5IN 			   ; P1 Input
loop:
	BL  GPIO_Input ; Input for P5.4 Switch
	CMP R0, #0x01  ; Check if Switch is p5.4 is pressed (neg logic)
	BEQ STATIC_LED ; If Switch p5.4 is pressed then go to Static LED
	B BLINKING_LED ; If Switch p5.4 is 'not pressed by default'...
				   ; then go to Blinking LED

STATIC_LED:

	PUSH {R3}     ; Save context
	MOV R3, #0x01 ; Need to set pin 2 to 1 to keep pull up
	STRB R3, [R1] ; LED on here
	POP {R3}      ; Restore context

	B loop		  ; loop back to main loop

TURN_ON_LED:
	MOV R3, #0x01 ; Need to set pin 2 to 1 to keep pull up
	STRB R3, [R1] ; LED on
	BX LR		  ; Continue in Toggle where last call was made

TURN_OFF_LED:
	MOV R3, #0x00 ; Need to set pin 2 to 1 to keep pull up
	STRB R3, [R1] ; LED off
	BX LR		  ; Continue in Toggle where last call was made

DELAY:
	                        ; updated delay - 187426 cycles now
	PUSH	{R0}			; Save context - Break point here for cycles 187426k or 60 ms
	MOV	R0, #DELAYIS62MS; Using constant declare value in global

DELAY_LOOP:
	SUB	R0, #0x01		; wait
	CMP	R0, #0x00		; Check if switch is not pressed
	BEQ	DONE			; If pressed done
	B	DELAY_LOOP		; Loop delay

DONE:
	POP	{R0}		    ; Restore context
	BX   	LR				; Continue from last instruction

BLINKING_LED:

	BL DELAY		; Branch to Delay
	BL TURN_OFF_LED ; Branch to Turn off LED
	BL DELAY		; Branch to Delay
	BL TURN_ON_LED  ; Branch to Turn on LED
	B  loop			; Back to loop
	.endasmfunc

EXTERNAL_LED_Init:	.asmfunc
	PUSH	{R0-R1}				 ; Save context

	; Init P4.0 and make them outputs
	LDR 	R1, P4SEL0
	LDRB	R0, [R1]
	BIC	R0, R0, #0x01        ; Configure pins as GPIO
	STRB	R0, [R1]

	LDR	R1, P4SEL1
	LDRB	R0, [R1]
	BIC	R0, R0, #0x01        ; Configure pins as GPIO
	STRB 	R0, [R1]

	; Make pins output
	LDR	R1, P4DIR
	LDRB	R0, [R1]
	ORR   R0, R0, #0x01        ; Output direction for p4.0
	STRB  R0, [R1]

	POP	{R0-R1}				 ; Restore context
	BX   	LR
			.endasmfunc

GPIO_Init:	.asmfunc
	PUSH	{R0-R1}				 ; Save context

	; Init P5.4 init
	LDR 	R1, P5SEL0
	LDRB	R0, [R1]
	BIC	R0, R0, #0x01       ; Configure pins as GPIO p5,4
	STRB	R0, [R1]

	LDR	R1, P5SEL1
	LDRB	R0, [R1]
	BIC	R0, R0, #0x01        ; Configure pins as GPIO p5.4
	STRB 	R0, [R1]

	; Make pins output
	LDR	R1, P5DIR
	LDRB	R0, [R1]
	BIC	R0, R0, #0x00        ; Set P5.4 as input  (0)
	STRB	R0, [R1]

       POP	{R0-R1}		         ; Restore context
	BX   	LR
			.endasmfunc

GPIO_Input: .asmfunc

	; Get P1 input and return via R0
	LDRB	R0, [R2]
	LSR	R0, #0x04				; Initialize P5.4 Input Logical shift to enable p5.4 since p5.0 is not working.
	BIC	R0, R0, #0xFE           ; Clear upper 7 bits

	BX   	LR
			.endasmfunc
	        .end
