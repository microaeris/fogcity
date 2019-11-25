#ifndef TEST_MODULE_API_H
#define TEST_MODULE_API_H

#include <test.h>

// C-struct designated initializers in C89
// Can't set label to value. Drop name tag when initializing.
// https://stackoverflow.com/questions/5440611/how-to-rewrite-c-struct-designated-initializers-to-c89-resp-msvc-c-compiler

test_module_api_t test_bank_helpers_api = {
    test_bank_helpers_init,
    test_bank_helpers_run,
};

#endif /* TEST_MODULE_API_H */
