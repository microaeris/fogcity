#include <stdio.h>
#include <macros.h>
#include <test.h>
#include <test_assert.h>
#include <test_module_api.h>

#define MAX_TEST_MODULES 16

uint8_t num_test_modules;
test_module_api_t test_module_api_list[MAX_TEST_MODULES];


void install_test_api(void)
{
    // Install all new test modules here
    test_module_api_list[num_test_modules++] = test_bank_helpers_api;

    test_assert(num_test_modules <= MAX_TEST_MODULES);
}

void print_result(uint8_t result)
{
    if (result == RESULT_SUCCESS) {
        printf("SUCCESS\n");
    } else {
        printf("FAIL\n");
    }
}

int main (void)
{
    test_result_t result;
    uint8_t i;

    install_test_api();

    printf("\n\nStarting...\n");
    for (i = 0; i < num_test_modules; ++i) {
        // Init test module
        test_assert((uint16_t)test_module_api_list[i].init);
        printf("Init Module %d:\t\t", i);
        result = test_module_api_list[i].init();
        print_result(result);

        // Run test module
        test_assert((uint16_t)test_module_api_list[i].run);
        printf("Testing Module %d:\t", i);
        result = test_module_api_list[i].run();
        print_result(result);
    }
    printf("Done.\n\n");

    return 0;
}
