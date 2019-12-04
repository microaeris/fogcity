#include <stdio.h>
#include <macros.h>
#include <test.h>

// For mocking `debug_assert`
uint8_t debug_asserted;


void test_assert(uint16_t expression)
{
    if (!expression) {
        printf("Asserted.\n");
        while (1);
    }
}

// Assert if expression is false
void test_true(uint16_t expression)
{
    test_assert(expression);
}

// Assert is expression is true
void test_false(uint16_t expression)
{
    test_assert(!expression);
}

void debug_assert(uint16_t expr)
{
    printf("Mock debug assert called.\n");
    debug_asserted = !expr;
}

void clear_debug_assert(void)
{
    debug_asserted = FALSE;
}

void test_debug_assert_called(void)
{
    test_assert(debug_asserted);
}

void test_debug_assert_not_called(void)
{
    test_assert(!debug_asserted);
}
