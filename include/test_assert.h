#ifndef TEST_ASSERT_H
#define TEST_ASSERT_H

#include <macros.h>

void test_assert(uint16_t expression);
void test_true(uint16_t expression);
void test_false(uint16_t expression);

void clear_debug_assert(void);
void test_debug_assert_called(void);
void test_debug_assert_not_called(void);

#endif /* TEST_ASSERT_H */
