#include <stdio.h>
#include <stdlib.h>

// Declare the assembly functions
extern void stop_flashing_led(void);
extern void led_switch(void);
extern void built_in_led(void);

int main() {
    // Call the assembly functions
    stop_flashing_led();
    led_switch();
    built_in_led();
    
    printf("All is good!\n");

    return 0;
}
