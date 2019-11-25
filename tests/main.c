#include <macros.h>

#pragma rodata-name ("EXEHDR")
#pragma code-name ("EXEHDR")

uint16_t __EXEHDR__ = 0;

#pragma rodata-name ("STARTUP")
#pragma code-name ("STARTUP")

uint16_t __STARTUP__ = 0;

#pragma rodata-name ("CODE")
#pragma code-name ("CODE")

int main (void)
{
    return 1;
}
