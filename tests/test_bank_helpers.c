#include <macros.h>
#include <test.h>
#include <test_assert.h>
#include <bank_helpers.h>

extern uint8_t debug_asserted;

test_result_t test_bank_helpers_init(void)
{
    return 0;
}

test_result_t test_bank_helpers_run(void)
{
    clear_debug_assert();
    banked_call(1, (void *)0);
    test_assert(debug_asserted);
    return 0;
}
