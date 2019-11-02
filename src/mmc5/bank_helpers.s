.segment "ZEROPAGE"
    PRG_BANK_0: .res 1  ; FIXME - remove since I won't use WRAM?
    PRG_BANK_1: .res 1
    PRG_BANK_2: .res 1
    PRG_BANK_3: .res 1
    PRG_BANK_4: .res 1
    nmiChrTileBank: .res 1
    .exportzp PRG_BANK_0, PRG_BANK_1, PRG_BANK_2, PRG_BANK_3, PRG_BANK_4
    .exportzp nmiChrTileBank

.segment "CODE"

.export _set_prg_bank_0, _set_prg_bank_1, _set_prg_bank_2
.export _set_prg_bank_3, _set_prg_bank_4
.export _get_prg_bank_0, _get_prg_bank_1, _get_prg_bank_2
.export _get_prg_bank_3, _get_prg_bank_4
.export _set_chr_bank_0, _set_chr_bank_1, _set_chr_bg_tile_bank
.export _set_prg_mode, _set_chr_mode, _set_mirroring
; FIXME - figure out what to do with these two functions
.export _set_nmi_chr_tile_bank, _unset_nmi_chr_tile_bank

; Setters for PRG bank switching

_set_prg_bank_0:
    sta PRG_BANK_0
    sta PRG_BANK_0_REG
    rts

_set_prg_bank_1:
    sta PRG_BANK_1
    sta PRG_BANK_1_REG
    rts

_set_prg_bank_2:
    sta PRG_BANK_2
    sta PRG_BANK_2_REG
    rts

_set_prg_bank_3:
    sta PRG_BANK_3
    sta PRG_BANK_3_REG
    rts

_set_prg_bank_4:
    sta PRG_BANK_4
    sta PRG_BANK_4_REG
    rts

; FIXME - remove these getters if not used?
; Get current bank in area

_get_prg_bank_0:
    lda PRG_BANK_0
    rts

_get_prg_bank_1:
    lda PRG_BANK_1
    rts

_get_prg_bank_2:
    lda PRG_BANK_2
    rts

_get_prg_bank_3:
    lda PRG_BANK_3
    rts

_get_prg_bank_4:
    lda PRG_BANK_4
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
    lda #PRG_BANK_0
    sta nmiChrTileBank
    rts
