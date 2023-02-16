; When SW1 is pressed, RED LED turns on
; Built-in LED1 connected to P1.0
; Negative logic built-in button 1 connected to P1.1
stop_flashing_led:   ; define function stop_flashing_led

.thumb
.text ; Following put in ROM 

; Port 1 Registers
P1IN    .word 0x40004C00 ; Port 1 Input
P1OUT   .word 0x40004C02 ; Port 1 Output
P1DIR   .word 0x40004C04 ; Port 1 Direction 
P1REN   .word 0x40004C06 ; Port 1 Resistor Enable 
P1DS    .word 0x40004C08 ; Port 1 Drive Strength
P1SEL0  .word 0x40004C0A ; Port 1 Select 0 
P1SEL1  .word 0x40004C0C ; Port 1 Select 1

.global asm_main
.thumbfunc asm_main

asm_main:
    .asmfunc ; Main
    BL GPIO_Init
    LDR R1, P1OUT ; R0 = Red LED
    ; P1 Input
loop:
    BL GPIO_Input
    CMP R0, #0x00 ; Check if SW pressed (neg logic)
    BEQ LED_TOGGLE ; If Sw2 is pressed then BEQ to toggle
    LDR R2, P1IN
    B RESET ; If Sw2 is not pressed, loop back to LED on

RESET:
    PUSH {R3} ; Save context
    MOV R3, #0x13 ; Need to set pin 2 to keep pull up
    STRB R3, [R1] ; LED on
    POP {R3} ; Restore context
    B loop ; loop back to main loop

TURN_ON_LED:
    PUSH {R3} ; Save context
    MOV R3, #0x13 ; Need to set pin 2 to keep pull up
    STRB R3, [R1] ; LED on
    POP {R3} ; Restore context
    B loop ; Loop back to main loop

TURN_OFF_LED:
    PUSH {R3} ; Save context
    MOV R3, #0x10 ; Need to set pin 2 to keep pull up
    STRB R3, [R1] ; LED off
    POP {R3} ; Restore context
    BL DELAY2 ; Branch to delay 2

DELAY:
    MOV R0, #65000 ; Delay interval (time in MS)
WAIT
    SUBS R0, R0, #0x01
    BNE WAIT ; Based on delay will wait and subs R0, R0, #0x01
    BL TURN_OFF_LED ; Branch to LED off switch

DELAY2:
    MOV R0, #65000 ; Delay interval (time in MS)
WAIT2
    SUBS R0, R0, #0x01
    BNE WAIT2 ; Based on delay will wait and subs R0, R0, #0x01
    BL TURN_ON_LED ; Branch to LED on switch

LED_TOGGLE:
    BL DELAY ;Branch to Delay
    .endasmfunc

; Initialize GPIO
GPIO_Init:
    .asmfunc
    PUSH {R0-R1} ; Save context

    ; Init P1 init
    LDR R1, P1SEL0
    LDRB R0, [R1]
    BIC R0, R0, #0x13 ; Configure pins as GPIO
    STRB R
