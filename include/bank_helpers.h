// Contains functions to help with working with multiple PRG/CHR banks

#ifndef BANK_HELPERS_H
#define BANK_HELPERS_H

#include <macros.h>

// Init needs to be called before any of the following functions.
void bank_helpers_init(void);

// Switch to another bank and call this function.
// Note: Using banked_call to call a second function from within
// another banked_call is safe. This will break if you nest more
// than 16 calls deep.
void banked_call(uint8_t bank_id, void (*method)(void));

// Switch to the given bank. Your prior bank is not saved.
// Can be used for reading data with a function in the fixed bank.
// bank_id: The bank to switch to.
void __fastcall__ set_prg_bank_1(uint8_t bank_id);
void __fastcall__ set_prg_bank_2(uint8_t bank_id);
void __fastcall__ set_prg_bank_3(uint8_t bank_id);

// Get the current PRG bank at $8000-bfff.
// returns: The current bank.
uint8_t __fastcall__ get_prg_bank_1(void);
uint8_t __fastcall__ get_prg_bank_2(void);
uint8_t __fastcall__ get_prg_bank_3(void);

// Set the current 1st 4k chr bank to the bank with this id.
void __fastcall__ set_chr_bank_0(uint8_t bank_id);

// Set the current 2nd 4k chr bank to the bank with this id.
void __fastcall__ set_chr_bank_1(uint8_t bank_id);

// Set the current mirroring mode. Your options are MIRROR_LOWER_BANK,
// MIRROR_UPPER_BANK, MIRROR_HORIZONTAL, and MIRROR_VERTICAL.
void __fastcall__ set_mirroring(uint8_t mirroring);

// Set the CHR BG tile bank.
void __fastcall__ set_chr_bg_tile_bank(uint8_t bank_id);

// Set the PRG mode.
void __fastcall__ set_prg_mode(uint8_t prg_mode);

// Set the CHR mode.
void __fastcall__ set_chr_mode(uint8_t chr_mode);

#endif /* BANK_HELPERS_H */
