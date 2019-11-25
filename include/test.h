#ifndef TEST_H
#define TEST_H

#include <macros.h>

typedef enum test_result_t {
    RESULT_SUCCESS = 0,
    RESULT_ERROR_GENERIC,
} test_result_t;

typedef test_result_t (*func_pointer_t)(void);

typedef struct test_module_api_t {
    func_pointer_t init;
    func_pointer_t run;
} test_module_api_t;

// Function and API Declarations

test_result_t test_bank_helpers_init(void);
test_result_t test_bank_helpers_run(void);

#endif /* TEST_H */
