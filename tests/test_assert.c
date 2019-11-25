#include <stdio.h>
#include <macros.h>

// Mock `debug_assert`

uint8_t debug_asserted;

void debug_assert(uint16_t expr)
{
    printf("Mock debug assert called.\n");
    debug_asserted = !expr;
}

void clear_debug_assert(void)
{
    debug_asserted = FALSE;
}

void test_assert(uint16_t expression)
{
    if (!expression) {
        printf("Asserted.\n");
        while (1);
    }
}
