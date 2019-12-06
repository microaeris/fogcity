#ifndef BANK_HELPERS_IMPL_H
#define BANK_HELPERS_IMPL_H

#include <macros.h>
#include <bank_helpers.h>

// Maximum level of recursion to allow with banked_call and similar functions.
#define MAX_BANK_DEPTH 16
#define ID_BITS             2
#define LRU_BANK_AREA_INIT  0x24    // 0b00100100
#define LRU_IDX_0_MASK      0x03    // 0b0000_0011
#define LRU_IDX_1_MASK      0x0C    // 0b0000_1100
#define LRU_IDX_2_MASK      0x30    // 0b0011_0000
#define GET_LRU(idx) ((lru_bank_area >> (idx * ID_BITS)) & LRU_IDX_0_MASK)

uint8_t bank_level;
uint8_t bank_buffer[MAX_BANK_DEPTH];

// Importing zero page variables
extern uint8_t PRG_BANK_1;
#pragma zpsym ("PRG_BANK_1");
extern uint8_t PRG_BANK_2;
#pragma zpsym ("PRG_BANK_2");
extern uint8_t PRG_BANK_3;
#pragma zpsym ("PRG_BANK_3");

typedef enum bank_area_id_t {
    PRG_BANK_AREA_1 = 0,
    PRG_BANK_AREA_2,
    PRG_BANK_AREA_3
} bank_area_id_t;

// Returns the bank area to load new bank into. Bank areas refer to the
// memory mapped regions of flash that a physical bank of flash on the
// cartridge is mapped to.
bank_area_id_t choose_bank_area(uint8_t bank_id);

// Internal function used by banked_call(), don't call this directly.
// Switch to the given bank, and keep track of the current bank, so that we
// may jump back to it as needed.
void bank_push(uint8_t bank_id, bank_area_id_t bank_area_id);

// Internal function used by banked_call(), don't call this directly.
// Go back to the last bank pushed on using bank_push.
void bank_pop(void);

#endif /* BANK_HELPERS_IMPL_H */
