; Linker generated symbols
    .import __BANK_00_LOAD__

.segment "ZEROPAGE"
    ; PRG_BANK_0: .res 1  ; FIXME - remove since I won't use WRAM?
    PRG_BANK_1: .res 1
    PRG_BANK_2: .res 1
    PRG_BANK_3: .res 1
    nmiChrTileBank: .res 1
    .exportzp PRG_BANK_1, PRG_BANK_2, PRG_BANK_3
    .exportzp nmiChrTileBank

.segment "CODE"

.export _set_prg_bank_1, _set_prg_bank_2, _set_prg_bank_3
.export _get_prg_bank_1, _get_prg_bank_2, _get_prg_bank_3
.export _set_chr_bank_0, _set_chr_bank_1, _set_chr_bg_tile_bank
.export _set_prg_mode, _set_chr_mode, _set_mirroring
; FIXME - figure out what to do with these two functions
.export _set_nmi_chr_tile_bank, _unset_nmi_chr_tile_bank


; Setters for PRG bank switching
; param a: bank index to load
;
; The setter will convert the index into the appropriate address
; bits to set in the bank switching register.

; _set_prg_bank_0:
;     sta PRG_BANK_0
;     sta PRG_BANK_0_REG
;     rts

; param a: [0x00, 0x29]
_set_prg_bank_1:
    sta PRG_BANK_1
    ldx __BANK_00_LOAD__  ; FIXME - how does this work? loading a 16 bit number into x?
    sta PRG_BANK_1_REG
    rts

; param a: [0x2A, 0x53]
_set_prg_bank_2:
    sta PRG_BANK_2
    sta PRG_BANK_2_REG
    rts

; param a: [0x54, 0x7E]
_set_prg_bank_3:
    sta PRG_BANK_3
    sta PRG_BANK_3_REG
    rts

; No setter for bank 4 because it is fixed


; FIXME - remove these getters if not used?
; Get current bank index in area
; return: bank index in register a

; _get_prg_bank_0:
;     lda PRG_BANK_0
;     rts

_get_prg_bank_1:
    lda PRG_BANK_1
    rts

_get_prg_bank_2:
    lda PRG_BANK_2
    rts

_get_prg_bank_3:
    lda PRG_BANK_3
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
    sta nmiChrTileBank
    rts

; for split screens with different CHR bank at top... disable it
_unset_nmi_chr_tile_bank:
    lda #PRG_BANK_1
    sta nmiChrTileBank
    rts
