#ifndef BANK_HELPERS_IMPL_H
#define BANK_HELPERS_IMPL_H

#include <macros.h>

// Maximum level of recursion to allow with banked_call and similar functions.
#define MAX_BANK_DEPTH 16

unsigned char bankLevel;
unsigned char bankBuffer[MAX_BANK_DEPTH];

// Importing zero page variables
extern unsigned char PRG_BANK_1;
#pragma zpsym ("PRG_BANK_1");
extern unsigned char PRG_BANK_2;
#pragma zpsym ("PRG_BANK_2");
extern unsigned char PRG_BANK_3;
#pragma zpsym ("PRG_BANK_3");

// Internal function used by banked_call(), don't call this directly.
// Switch to the given bank, and keep track of the current bank, so that we
// may jump back to it as needed.
void bank_push(unsigned char bankId);

// Internal function used by banked_call(), don't call this directly.
// Go back to the last bank pushed on using bank_push.
void bank_pop(void);

#endif /* BANK_HELPERS_IMPL_H */
