#include "lib/neslib.h"
#include "lib/nesdoug.h"
#include "nes_st/bg_test.h"

const unsigned char palette[]={
    0x0f, 0x17, 0x27, 0x36,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
};

void main (void) {
    ppu_off(); // screen off

    pal_bg(palette); // load the palette

    vram_adr(NAMETABLE_A);
    // this sets a start position on the BG, top left of screen
    // vram_adr() and vram_unrle() need to be done with the screen OFF

    vram_unrle(bg_test);
    // this unpacks an rle compressed full nametable
    // created by NES Screen Tool

    ppu_on_all(); // turn on screen

    while (1){
        // infinite loop
        // game code can go here later.
    }
}