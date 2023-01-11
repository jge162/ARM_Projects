; When SW1 is pressed, RED LED turns on
; Built-in LED1 connected to P1.0
; Negative logic built-in button 1 connected to P1.1
.thumb
.text ; Following put in ROM ; Port 1 Registers
 P1IN
P1OUT
P1DIR
P1REN
P1DS
P1SEL0 .word 0x40004C0A ; Port 1 Select 0 P1SEL1 .word 0x40004C0C ; Port 1 Select 1
.word 0x40004C00 ; Port 1 Input
.word 0x40004C02 ; Port 1 Output
.word 0x40004C04 ; Port 1 Direction .word 0x40004C06 ; Port 1 Resistor Enable .word 0x40004C08 ; Port 1 Drive Strength
.global asm_main .thumbfunc asm_main
asm_main: .asmfunc ; Main BL GPIO_Init LDR R1, P1OUT
; R0 = Red LED
  ; P1 Input
loop:
RESET:
TURN_ON_LED:
TURN_OFF_LED:
BL GPIO_Input
CMP R0, #0x00 ; Check if SW pressed (neg logic)
BEQ LED_TOGGLE ; If Sw2 is pressed then BEQ to toggle
LDR R2, P1IN
B RESET
; If Sw2 is not pressed
loop back to LED on
to keep pull up
to keep pull up
to keep pull up
PUSH {R3}
MOV R3, #0x13
STRB R3, [R1] ; LED on
to 1 loop
to 1 loop
to 1
POP {R3} B loop
; Restore context
; loop back to main
PUSH {R3}
MOV R3, #0x13
STRB R3, [R1] ; LED on
; Save context
; Need to set pin 2
; Save context
; Need to set pin 2
POP {R3} B loop
PUSH {R3}
MOV R3, #0x10
STRB R3, [R1] ; LED off
POP {R3} ; Restore context BL DELAY2 ; Branch to delay 2
; Restore context
; Loop back to main
; Save context
; Need to set pin 2
5
DELAY:
MOV R0,#65000 ; Delay interval (time in MS) WAIT SUBS R0,R0,#0x01
BNE WAIT ; Based on delay will wait and subs R0, R0, #0x01 BL TURN_OFF_LED ; Branch to LED off switch
DELAY2:
MOV R0,#65000 ; Delay interval (time in MS) WAIT2 SUBS R0,R0,#0x01
LED_TOGGLE:
BNE WAIT2 ; Based on delay will wait and subs R0, R0, #0x01 BL TURN_ON_LED ; Branch to LED on switch
BL DELAY ;Branch to Delay .endasmfunc
GPIO_Init: .asmfunc
PUSH {R0-R1} ; Save context
; Init P1 init
             LDR R1, P1SEL0
             LDRB R0, [R1]
             BIC R0, R0, #0x13
             STRB R0, [R1]
             LDR R1, P1SEL1
             LDRB R0, [R1]
             BIC R0, R0, #0x13
             STRB R0, [R1]
        ; Make pins output
             LDR R1, P1DIR
             LDRB R0, [R1]
             BIC R0, R0, #0x10
             ORR R0, R0, #0x01
             STRB R0, [R1]
        ; Enable pull resistors on P1.4
; Configure pins as GPIO
; Configure pins as GPIO
; Set P1.4 as input (0)
; Set P1.0 as output (1)
LDR  R1, P1REN
LDRB R0, [R1]
ORR  R0, R0, #0x10           ; Enable pull resistor
STRB R0, [R1]
 ; Enable pull resistors on P1.4
LDR  R1, P1OUT
LDRB R0, [R1]
ORR  R0, R0, #0x10
STRB R0, [R1]
POP {R0-R1} ; Restore context
       BX   LR
       .endasmfunc
; Enable pull-up resistor
6

GPIO_Input: .asmfunc
LDRB R0, [R2]
; Get P1.4 input and return via R0
      ; Shift to the right 4 to use p1.4
; Clear upper 7 bits
switch
LSR R0, #0x04
BIC R0, R0, #0xFE
BX LR
     .endasmfunc
.end
