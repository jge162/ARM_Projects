#include <stdio.h>
#include <stdlib.h>

extern void asm_main();

int main() {
    // Call the assembly function
    asm_main();
    
    printf("success")
        
    return 0;
}
