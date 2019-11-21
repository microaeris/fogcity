// NOTE: These functions must be located in the fixed bank.
#pragma rodata-name ("CODE")
#pragma code-name ("CODE")


// Maximum level of recursion to allow with banked_call and similar functions.
#define MAX_BANK_DEPTH 16

unsigned char bankLevel;
unsigned char bankBuffer[MAX_BANK_DEPTH];

// Importing zero page variables
extern unsigned char PRG_BANK_1;
#pragma zpsym ("PRG_BANK_1");


void banked_call(unsigned char bankId, void (*method)(void))
{
    if (bankId == PRG_BANK_1) {
        return;
    }
    (void)method;
//     bank_push(bankId);
//     (*method)();
//     bank_pop();
}

// // Internal function used by banked_call(), don't call this directly.
// // Switch to the given bank, and keep track of the
// // current bank, so that we may jump back to it as needed.

// void bank_push(unsigned char bankId) {
//     bankBuffer[bankLevel] = bankId;
//     ++bankLevel;
// // removed error code
//     set_prg_bank(bankId);
// }

// // Internal function used by banked_call(), don't call this directly.
// // Go back to the previous bank

// void bank_pop(void) {
//     --bankLevel;
//     if (bankLevel > 0) {
//         set_prg_bank(bankBuffer[bankLevel-1]);
//     }
// }
