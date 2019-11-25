// Contains functions to help with working with multiple PRG/CHR banks

#ifndef BANK_HELPERS_H
#define BANK_HELPERS_H

#include <macros.h>

// Switch to another bank and call this function.
// Note: Using banked_call to call a second function from within
// another banked_call is safe. This will break if you nest more
// than 16 calls deep.
void banked_call(unsigned char bankId, void (*method)(void));

// Switch to the given bank. Your prior bank is not saved.
// Can be used for reading data with a function in the fixed bank.
// bank_id: The bank to switch to.
void __fastcall__ set_prg_bank(unsigned char bank_id);

// Get the current PRG bank at $8000-bfff.
// returns: The current bank.
unsigned char __fastcall__ get_prg_bank(void);


// Set the current 1st 4k chr bank to the bank with this id.
void __fastcall__ set_chr_bank_0(unsigned char bank_id);


// Set the current 2nd 4k chr bank to the bank with this id.
void __fastcall__ set_chr_bank_1(unsigned char bank_id);

// Set the current mirroring mode. Your options are MIRROR_LOWER_BANK,
// MIRROR_UPPER_BANK, MIRROR_HORIZONTAL, and MIRROR_VERTICAL.
void __fastcall__ set_mirroring(unsigned char mirroring);


// Set all 5 bits of the $8000 MMC1 Control register (not recommended)
void __fastcall__ set_mmc1_ctrl(unsigned char value);


// Set what chr bank to set at the top of the screen, for a split screen.
void __fastcall__ set_nmi_chr_tile_bank(unsigned char bank);


// Don't change the chr bank at the top of the screen.
void __fastcall__ unset_nmi_chr_tile_bank(void);

#endif /* BANK_HELPERS_H */
