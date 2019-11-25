#include <macros.h>

void debug_assert(uint16_t expr)
{
    if (!expr) {
        // TODO - print something to the screen on assert
        // Maybe change the color palette?
        while (TRUE);
    }
}
