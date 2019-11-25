#include <stdio.h>
#include <macros.h>

void test_assert(uint16_t expression)
{
    if (!expression) {
        printf("Asserted.\n");
        while (1);
    }
}
