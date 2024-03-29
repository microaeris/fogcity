#include "lib/neslib.h"
#include "lib/nesdoug.h"
#include "nes_st/bg_test.h"
#include "include/bank_helpers.h"

#pragma rodata-name ("BANK_00")
#pragma code-name ("BANK_00")
const uint8_t TEXT_00[]="BANK_00";

void function_bank_00(void){
    ppu_off();
    vram_adr(NTADR_A(1,6));
    vram_write(TEXT_00,sizeof(TEXT_00));
    ppu_on_all();
}

#pragma rodata-name ("CODE")
#pragma code-name ("CODE")
const uint8_t text[]="FIXED BANK";

// const uint8_t palette[]={
//     0x0f, 0x17, 0x27, 0x36,
//     0x00, 0x00, 0x00, 0x00,
//     0x00, 0x00, 0x00, 0x00,
//     0x00, 0x00, 0x00, 0x00,
// };

#define BLACK 0x0f
#define DK_GY 0x00
#define LT_GY 0x10
#define WHITE 0x30

const unsigned char palette[]={
BLACK, DK_GY, LT_GY, WHITE,
0,0,0,0,
0,0,0,0,
0,0,0,0
};

void function_bank_code(void){
    ppu_off();
    vram_adr(NTADR_A(1,2));
    vram_write(text, sizeof(text));
    ppu_on_all();
}

void main (void) {
    ppu_off(); // screen off

    pal_bg(palette); // load the palette
    pal_spr(palette); // load the sprite palette

    vram_adr(NAMETABLE_A);
    // this sets a start position on the BG, top left of screen
    // vram_adr() and vram_unrle() need to be done with the screen OFF

    // vram_unrle(bg_test);
    // this unpacks an rle compressed full nametable
    // created by NES Screen Tool

    ppu_on_all(); // turn on screen

    function_bank_code();
    bank_helpers_init();
    banked_call(0x00, function_bank_00);

    while (1){
        // infinite loop
        // game code can go here later.
    }
}
