.segment "ZEROPAGE"

; PRG_BANK_0: .res 1  ; FIXME - remove since I won't use WRAM?
_PRG_BANK_1: .res 1
_PRG_BANK_2: .res 1
_PRG_BANK_3: .res 1
_nmiChrTileBank: .res 1
.exportzp _PRG_BANK_1, _PRG_BANK_2, _PRG_BANK_3
.exportzp _nmiChrTileBank


.segment "CODE"

.export _set_prg_bank_1, _set_prg_bank_2, _set_prg_bank_3
.export _get_prg_bank_1, _get_prg_bank_2, _get_prg_bank_3
.export _set_chr_bank_0, _set_chr_bank_1, _set_chr_bg_tile_bank
.export _set_prg_mode, _set_chr_mode, _set_mirroring
; FIXME - figure out what to do with these two functions
;.export _set_nmi_chr_tile_bank, _unset_nmi_chr_tile_bank


BANK_SIZE_HI = $20  ; High byte of $2000, the PRG bank size in Mode 3


; Calculate the 16-bit address of the bank
;
; Calculates (bank_idx * size of each bank). Then shifts the top three bits of
; the lower byte into the higher byte. MMC5 only needs the top 7 bits of this
; operation.
;
; This function always selects ROM as the memory type. This should be changed
; if my game ever uses extended RAM.
;
; To Do:
;     Use a jump table instead of calculating the address values dynamically.
;     if performance is an issue.
;
; Args:
;     a: bank index to load. [0x00, 0x7E]
;
; Returns:
;     None
_calc_bank_addr:
    sta MULT_16_LO_REG
    ldx #BANK_SIZE_HI
    stx MULT_16_HI_REG
    ; Loop 1
    lda MULT_16_LO_REG
    asl A
    tax  ; x holds low byte
    lda MULT_16_HI_REG
    rol A
    ; Loop 2
    tay  ; y holds the high byte
    txa
    asl A
    tax
    tya
    rol A
    ; Loop 3
    tay
    txa
    asl A
    tax
    tya
    rol A
    ; Select ROM
    ORA #PRG_ROM_SELECT
    rts


; Setters for PRG bank switching
;
; The setter will convert the index into the appropriate address
; bits to set in the bank switching register.
; Note, there is no setter for bank 4 because it is fixed.
;
; Args:
;     a: bank index to load
;
; Returns:
;     None

; _set_prg_bank_0:
;     sta PRG_BANK_0
;     sta PRG_BANK_0_REG
;     rts

; param a: [0x00, 0x29]
_set_prg_bank_1:
    sta _PRG_BANK_1
    jsr _calc_bank_addr
    sta PRG_BANK_1_REG
    rts

; param a: [0x2A, 0x53]
_set_prg_bank_2:
    sta _PRG_BANK_2
    jsr _calc_bank_addr
    sta PRG_BANK_2_REG
    rts

; param a: [0x54, 0x7E]
_set_prg_bank_3:
    sta _PRG_BANK_3
    jsr _calc_bank_addr
    sta PRG_BANK_3_REG
    rts


; FIXME - remove these getters if not used?
; Get current bank index in area
; return: bank index in register a

; _get_prg_bank_0:
;     lda PRG_BANK_0
;     rts

_get_prg_bank_1:
    lda _PRG_BANK_1
    rts

_get_prg_bank_2:
    lda _PRG_BANK_2
    rts

_get_prg_bank_3:
    lda _PRG_BANK_3
    rts


; Setters for CHR bank areas in mode 1

_set_chr_bank_0:
    sta CHR_BANK_3_REG
    rts

_set_chr_bank_1:
    sta CHR_BANK_7_REG
    rts

; Only relevant when using 8x16 sprites
_set_chr_bg_tile_bank:
    sta CHR_BANK_B_REG
    rts

; Setters for MMC5 Configurations

_set_prg_mode:
    sta PRG_MODE_REG
    rts

_set_chr_mode:
    sta CHR_MODE_REG
    rts

_set_mirroring:
    sta NAMETABLE_MAPPING_REG
    rts

; FIXME - figure out what I want to do in these two functions for MMC5
; for split screens with different CHR bank at top
_set_nmi_chr_tile_bank:
    sta _nmiChrTileBank
    rts

; for split screens with different CHR bank at top... disable it
_unset_nmi_chr_tile_bank:
    lda #_PRG_BANK_1
    sta _nmiChrTileBank
    rts
