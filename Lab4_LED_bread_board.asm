; When SW1 is pressed, RED LED turns on

; Built-in LED1 connected to P4.0
; Negative logic built-in button 1 connected to P5.4

.thumb

.text ; Following put in ROM
; Port 5 Registers
P5IN        .word    0x40004C40        ; Port 5 Input
P5OUT       .word    0x40004C42        ; Port 5 Output
P5DIR       .word    0x40004C44        ; Port 5 Direction
P5SEL0      .word    0x40004C4A        ; Port 5 Select 0
P5SEL1      .word    0x40004C4C        ; Port 5 Select 1

; Port 4 Registers
P4IN        .word    0x40004C21        ; Port 5 Input
P4OUT       .word    0x40004C23        ; Port 5 Output
P4DIR       .word    0x40004C25        ; Port 5 Direction
P4SEL0      .word    0x40004C2B        ; Port 5 Select 0
P4SEL1      .word    0x40004C2D        ; Port 5 Select 1

;***************Constants**************************
DELAYIS100MS	.equ    0xFFFF ; 100 ms testing...
;DELAYIS100MS	.equ	0x1    ; For debugging only
;**************************************************
		.global asm_main
		.thumbfunc asm_main

asm_main: .asmfunc             ; Main

	BL   EXTERNAL_LED_Init ; Init for P4.0
	BL   GPIO_Init			   ; Init for P5.4
	LDR  R1, P4OUT             ; R0 = Red LED
	LDR  R2, P5IN 			   ; P1 Input

;***************************************************************
; Loop functions below
;***************************************************************
loop:
	BL  GPIO_Input ; Input for P5.4 Switch
	CMP R0, #0x01  ; Check if Switch is p5.4 is pressed (neg logic
	BEQ TRAFFIC_LIGHT_PHASE_1 ; If Switch p5.4 is 'not pressed by default'...
	CMP R12, #0x01
	BEQ loop3
	B START_PHASE_1

loop2:
	BL  GPIO_Input ; Input for P5.4 Switch
	CMP R0, #0x01  ; Check if Switch is p5.4 is pressed (neg logi
	BEQ TRAFFIC_LIGHT_PHASE_2 ; If Switch p5.4 is 'not pressed by default'..
	CMP R12, #0x01
	BEQ loop3
	B START_PHASE_2

loop3:
	BL  GPIO_Input ; Input for P5.4 Switch
	BL DELAY		; Branch to Delay
	CMP R12, #0x01
	BEQ TRAFFIC_LIGHT_PHASE_3
	B loop

;***************************************************************
; Static phases below
;***************************************************************

START_PHASE_1:
	MOV  R3, #0x82 ; Port P4.7   -> GREEN LED TOP -> RED LED BOTTOM
	STRB R3, [R1]  ; LED on here
	B loop		   ; loop back to main loop

START_PHASE_2:
	MOV  R3, #0x21 ; P4.5 & P4.0 -> RED LED TOP -> GREEN LED BOTTOM
	STRB R3, [R1]  ; LED on here
	B loop2 ; testing loop3 originally loop2

START_PHASE_3:
	BL DELAY		; Branch to Delay
	MOV  R3, #0x82 ; P4.5 & P4.0 -> GREEN LED TOP -> RED LED BOTTOM
	STRB R3, [R1] ; LED on here
	CMP R12, #0x00
	BEQ loop

;***************************************************************
; Light functions below
;***************************************************************

FUNC_YELLOW:
	MOV  R3, #0x12 ; Port P4.2 - YELLOW TOP & RED LED BOTTOM
	STRB R3, [R1]  ; LED on here
	BX LR

FUNC_GREEN:
	MOV  R3, #0x21 ; Port P4.1 - GREEN LED TOP RED BOTTOM
	STRB R3, [R1]  ; LED on here
	BX LR

FUNC_YELLOW2:
	MOV  R3, #0x24 ; Port P4.2 - YELLOW BOTTOM & RED LED TOP
	STRB R3, [R1]  ; LED on here
	BX LR

FUNC_GREEN2:
	MOV  R3, #0x82 ; Port P4.1 - GREEN LED TOP RED BOTTOM
	STRB R3, [R1]  ; LED on here
	BX LR

;***************************************************************
;Traffic Light Phases below
;***************************************************************

TRAFFIC_LIGHT_PHASE_1:
	BL DELAY		; Branch to Delay
	BL FUNC_YELLOW
	BL DELAY		; Branch to Delay
	BL FUNC_GREEN
	BL DELAY		; Branch to Delay
	CMP R0, #0X01
	BEQ loop2

TRAFFIC_LIGHT_PHASE_2:
	BL DELAY		; Branch to Delay
	BL FUNC_YELLOW2
	BL DELAY		; Branch to Delay
	CMP R7, #0X01
	BEQ loop
	BL DELAY		; Branch to Delay
	BL FUNC_GREEN
	b loop

TRAFFIC_LIGHT_PHASE_3:
	BL DELAY		; Branch to Delay
	BL FUNC_YELLOW
	BL DELAY		; Branch to Delay
	BL FUNC_GREEN
	BL DELAY		; Branch to Delay
	BL FUNC_YELLOW2
	BL DELAY		; Branch to Delay
	BL FUNC_GREEN2
	BL DELAY		; Branch to Delay
	b loop3
		.endasmfunc

;***************************************************************
; Init functions below
;***************************************************************

EXTERNAL_LED_Init:	.asmfunc
	PUSH	{R0-R1}				 ; Save context

	; Init P4.0 and make them outputs
	LDR 	R1, P4SEL0
	LDRB	R0, [R1]
	BIC		R0, R0, #0x01     ; Configure pins as GPIO
	STRB	R0, [R1]

	LDR		R1, P4SEL1
	LDRB	R0, [R1]
	BIC		R0, R0, #0x01     ; Configure pins as GPIO
	STRB 	R0, [R1]
	; Make pins output

	LDR		R1, P4DIR
	LDRB	R0, [R1]
	ORR		R0, R0, #0x21     ; Output direction for p4.0 (0x01) GREEN LED BOTTOM & p4.5 (0x20) RED LED TOP
	STRB	R0, [R1]

	LDR		R1, P4DIR
	LDRB	R0, [R1]
	ORR		R0, R0, #0x12     ; Output direction for p4.1 (0x02) RED LED BOTTOM & p4.4 (0x10) YELLOW LED TOP
	STRB	R0, [R1]

	LDR		R1, P4DIR
	LDRB	R0, [R1]
	ORR		R0, R0, #0x84     ; Output direction for p4.2 (0x04) YELLOW LED BOTTOM & p4.7 (0x80) GREEN LED TOP
	STRB	R0, [R1]

	POP		{R0-R1}			  ; Restore context
	BX   	LR
			.endasmfunc


GPIO_Init:	.asmfunc
	PUSH	{R0-R1}				 ; Save context

	; Init P5.4 init
	LDR 	R1, P5SEL0
	LDRB	R0, [R1]
	BIC		R0, R0, #0x10       ; Configure pins as GPIO p5,4
	STRB	R0, [R1]

	LDR		R1, P5SEL1
	LDRB	R0, [R1]
	BIC		R0, R0, #0x10       ; Configure pins as GPIO p5.4
	STRB 	R0, [R1]

	; Make pins output
	LDR		R1, P5DIR
	LDRB	R0, [R1]
	BIC		R0, R0, #0x00        ; Set P5.4 as input  (0)
	STRB	R0, [R1]

    POP		{R0-R1}		         ; Restore context
	BX   	LR
			.endasmfunc

;***************************************************************
; Input functions
;***************************************************************
GPIO_Input: .asmfunc
	PUSH	{LR}

	; Get P1 input and return via R0
	LDRB	R0,  [R2]
	LDRB    R7,  [R2]
	LDRB    R10, [R2]
	LDRB    R11, [R2]

	LSR		R0,  #0x04				; Shift to the right 4
	LSR     R7,  #0x02
	LSR		R10, #0X04
	LSR     R11, #0X02

	BIC		R0, R0, #0xFE           ; Clear upper 7 bits
    BIC     R7, R7, #0xFE           ; Clear upper 7 bits
	BIC		R10, R10, #0xFE
	BIC		R11, R11, #0xFE

	AND     R12, R11, R10
	EOR     R0, R0, R7
	EOR     R7, R7, R0

	BIC		R0, R0, #0xFE           ; Clear upper 7 bits
    BIC     R7, R7, #0xFE
	BIC		R12, R12, #0xFE

	CMP		R0, #0x00				; If not pressed
	BEQ		SKIP
	; Else if pressed
	BL		DELAY					; Debounce

SKIP:
	POP		{LR}
	BX   	LR
			.endasmfunc

;***************************************************************
; Delay functions below
;***************************************************************

DELAY:	.asmfunc
	; Inefficient delay - waste cycles
	PUSH	{R0}					; Save context
	MOV		R0, #DELAYIS100MS

DELAY_LOOP:
	SUB		R0, #0x01
	CMP		R0, #0x00
	BEQ		DONE
	B		DELAY_LOOP

DONE:
	POP		{R0}					; Restore context
	BX   	LR
			.endasmfunc
	        .end
;***************************************************************
; End program and functions here
;***************************************************************
