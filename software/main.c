#define LED_REG_ADDR  0x40000000
#define LED_REG        (*(volatile unsigned int *)LED_REG_ADDR)

int main(void) {
    // Declaring loop variables inside main removes function jumping overhead
    volatile unsigned int count;

    while (1) {
        LED_REG = 1;        // Turn LED ON
        
        // Inline Delay 1
        count = 20;         // Tiny value for short simulation window
        while (count > 0) { count--; }

        LED_REG = 0;        // Turn LED OFF
        
        // Inline Delay 2
        count = 20; 
        while (count > 0) { count--; }
    }
    return 0;
}
