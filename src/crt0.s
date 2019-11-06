; Startup code for cc65 and Shiru's NES library
; based on code by Groepaz/Hitmen <groepaz@gmx.net>, Ullrich von Bassewitz <uz@cc65.org>

FT_BASE_ADR     = $0100     ;page in RAM, should be $xx00
FT_DPCM_OFF     = $f000     ;$c000..$ffc0, 64-byte steps
FT_SFX_STREAMS  = 1         ;number of sound effects played at once, 1..4

FT_THREAD       = 1     ;undefine if you call sound effects in the same thread as sound update
FT_PAL_SUPPORT  = 1     ;undefine to exclude PAL support
FT_NTSC_SUPPORT = 1     ;undefine to exclude NTSC support
FT_DPCM_ENABLE  = 0     ;undefine to exclude all DMC code
FT_SFX_ENABLE   = 1     ;undefine to exclude all sound effects code

;REMOVED initlib
;this called the CONDES function

    .export _exit,__STARTUP__:absolute=1
    .import push0,popa,popax,_main,zerobss,copydata

; Linker generated symbols
    .import __STACK_START__ ,__STACKSIZE__
    .import __ROM0_START__  ,__ROM0_SIZE__
    .import __STARTUP_LOAD__,__STARTUP_RUN__,__STARTUP_SIZE__
    .import __CODE_LOAD__   ,__CODE_RUN__   ,__CODE_SIZE__
    .import __RODATA_LOAD__ ,__RODATA_RUN__ ,__RODATA_SIZE__
    .import NES_MAPPER, NES_PRG_BANKS, NES_CHR_BANKS, NES_MIRRORING

    .importzp _PAD_STATE, _PAD_STATET
    .include "zeropage.inc"

PPU_CTRL    =$2000
PPU_MASK    =$2001
PPU_STATUS  =$2002
PPU_OAM_ADDR=$2003
PPU_OAM_DATA=$2004
PPU_SCROLL  =$2005
PPU_ADDR    =$2006
PPU_DATA    =$2007
PPU_OAM_DMA =$4014
PPU_FRAMECNT=$4017
DMC_FREQ    =$4010
CTRL_PORT1  =$4016
CTRL_PORT2  =$4017  ; Controller input data register

OAM_BUF     =$0200
PAL_BUF     =$01c0
VRAM_BUF    =$0700


; Linker requires at least one mention of each bank
; FIXME - remove me once they are not needed here and are used elsewhere.
.segment "ONCE"
.segment "XRAM"
.segment "CHR_00"
.segment "CHR_01"
.segment "BANK_00"
    .byte $42, $41, $4e, $4b, $30, $30
.segment "BANK_01"
    .byte $42, $41, $4e, $4b, $30, $31
.segment "BANK_02"
    .byte $42, $41, $4e, $4b, $30, $32
.segment "BANK_03"
.segment "BANK_04"
.segment "BANK_05"
.segment "BANK_06"
.segment "BANK_07"
.segment "BANK_08"
.segment "BANK_09"
.segment "BANK_0A"
.segment "BANK_0B"
.segment "BANK_0C"
.segment "BANK_0D"
.segment "BANK_0E"
.segment "BANK_0F"
.segment "BANK_10"
.segment "BANK_11"
.segment "BANK_12"
.segment "BANK_13"
.segment "BANK_14"
.segment "BANK_15"
.segment "BANK_16"
.segment "BANK_17"
.segment "BANK_18"
.segment "BANK_19"
.segment "BANK_1A"
.segment "BANK_1B"
.segment "BANK_1C"
.segment "BANK_1D"
.segment "BANK_1E"
.segment "BANK_1F"
.segment "BANK_20"
.segment "BANK_21"
.segment "BANK_22"
.segment "BANK_23"
.segment "BANK_24"
.segment "BANK_25"
.segment "BANK_26"
.segment "BANK_27"
.segment "BANK_28"
.segment "BANK_29"
.segment "BANK_2A"
.segment "BANK_2B"
.segment "BANK_2C"
.segment "BANK_2D"
.segment "BANK_2E"
.segment "BANK_2F"
.segment "BANK_30"
.segment "BANK_31"
.segment "BANK_32"
.segment "BANK_33"
.segment "BANK_34"
.segment "BANK_35"
.segment "BANK_36"
.segment "BANK_37"
.segment "BANK_38"
.segment "BANK_39"
.segment "BANK_3A"
.segment "BANK_3B"
.segment "BANK_3C"
.segment "BANK_3D"
.segment "BANK_3E"
.segment "BANK_3F"
.segment "BANK_40"
.segment "BANK_41"
.segment "BANK_42"
.segment "BANK_43"
.segment "BANK_44"
.segment "BANK_45"
.segment "BANK_46"
.segment "BANK_47"
.segment "BANK_48"
.segment "BANK_49"
.segment "BANK_4A"
.segment "BANK_4B"
.segment "BANK_4C"
.segment "BANK_4D"
.segment "BANK_4E"
.segment "BANK_4F"
.segment "BANK_50"
.segment "BANK_51"
.segment "BANK_52"
.segment "BANK_53"
.segment "BANK_54"
.segment "BANK_55"
.segment "BANK_56"
.segment "BANK_57"
.segment "BANK_58"
.segment "BANK_59"
.segment "BANK_5A"
.segment "BANK_5B"
.segment "BANK_5C"
.segment "BANK_5D"
.segment "BANK_5E"
.segment "BANK_5F"
.segment "BANK_60"
.segment "BANK_61"
.segment "BANK_62"
.segment "BANK_63"
.segment "BANK_64"
.segment "BANK_65"
.segment "BANK_66"
.segment "BANK_67"
.segment "BANK_68"
.segment "BANK_69"
.segment "BANK_6A"
.segment "BANK_6B"
.segment "BANK_6C"
.segment "BANK_6D"
.segment "BANK_6E"
.segment "BANK_6F"
.segment "BANK_70"
.segment "BANK_71"
.segment "BANK_72"
.segment "BANK_73"
.segment "BANK_74"
.segment "BANK_75"
.segment "BANK_76"
.segment "BANK_77"
.segment "BANK_78"
.segment "BANK_79"
.segment "BANK_7A"
.segment "BANK_7B"
.segment "BANK_7C"
.segment "BANK_7D"
.segment "BANK_7E"



.segment "ZEROPAGE"

NTSC_MODE:          .res 1
FRAME_CNT1:         .res 1
FRAME_CNT2:         .res 1
VRAM_UPDATE:        .res 1
NAME_UPD_ADR:       .res 2
NAME_UPD_ENABLE:    .res 1
PAL_UPDATE:         .res 1
PAL_BG_PTR:         .res 2
PAL_SPR_PTR:        .res 2
SCROLL_X:           .res 1
SCROLL_Y:           .res 1
SCROLL_X1:          .res 1
SCROLL_Y1:          .res 1
PAD_STATE:          .res 2  ; one byte per controller
PAD_STATEP:         .res 2
PAD_STATET:         .res 2
PPU_CTRL_VAR:       .res 1
PPU_CTRL_VAR1:      .res 1
PPU_MASK_VAR:       .res 1
RAND_SEED:          .res 2
FT_TEMP:            .res 3

TEMP:               .res 11

PAD_BUF     =TEMP+1

PTR         =TEMP   ;word
LEN         =TEMP+2 ;word
NEXTSPR     =TEMP+4
SCRX        =TEMP+5
SCRY        =TEMP+6
SRC         =TEMP+7 ;word
DST         =TEMP+9 ;word

RLE_LOW     =TEMP
RLE_HIGH    =TEMP+1
RLE_TAG     =TEMP+2
RLE_BYTE    =TEMP+3

;nesdoug code requires
VRAM_INDEX:         .res 1
META_PTR:           .res 2
DATA_PTR:           .res 2


.segment "HEADER"

    .byte $4e,$45,$53,$1a ; NES<EOF>
    .byte <NES_PRG_BANKS
    .byte <NES_CHR_BANKS
    .byte <NES_MIRRORING|(<NES_MAPPER<<4)  ; Flag 6
    .byte <NES_MAPPER&$F0  ; iNES format
    .res 3,0
    .byte $41,$45,$52,$49,$53 ; AERIS


.segment "STARTUP"

start:
_exit:
    sei
    cld
    ldx #$40
    stx CTRL_PORT2     ; FIXME - why are we writing $40 to an input register?
    ldx #$ff
    txs                ; FIXME - Why are we putting FF on the stack? so confuse
    inx
    stx PPU_MASK
    stx DMC_FREQ
    stx PPU_CTRL        ;no NMI

; ; MMC5 reset
;     lda #PRG_MODE_3       ; FIXME - remove this set since mode 3 is default?
;     jsr _set_prg_mode

;     lda #CHR_MODE_1
;     jsr _set_chr_mode

;     lda #NAMETABLE_HORIZ
;     jsr _set_mirroring

;     lda #$00
;     jsr _set_prg_bank_1

;     lda #$2A
;     jsr _set_prg_bank_2

;     lda #$54
;     jsr _set_prg_bank_3

;     lda #$00 ;CHR bank #0 for first tile set
;     jsr _set_chr_bank_0

;     lda #$01 ;CHR bank #1 for second tile set
;     jsr _set_chr_bank_1

initPPU:
    bit PPU_STATUS
@1:
    bit PPU_STATUS
    bpl @1
@2:
    bit PPU_STATUS
    bpl @2

clearPalette:
    lda #$3f
    sta PPU_ADDR
    stx PPU_ADDR
    lda #$0f
    ldx #$20
@1:
    sta PPU_DATA
    dex
    bne @1

clearVRAM:
    txa
    ldy #$20
    sty PPU_ADDR
    sta PPU_ADDR
    ldy #$10
@1:
    sta PPU_DATA
    inx
    bne @1
    dey
    bne @1

clearRAM:
    txa
@1:
    sta $000,x
    sta $100,x
    sta $200,x
    sta $300,x
    sta $400,x
    sta $500,x
    sta $600,x
    sta $700,x
    inx
    bne @1

    lda #4
    jsr _pal_bright
    jsr _pal_clear
    jsr _oam_clear

    jsr zerobss
    jsr copydata

    lda #<(__STACK_START__+__STACKSIZE__) ;changed
    sta sp
    lda #>(__STACK_START__+__STACKSIZE__)
    sta sp+1            ; Set argument stack ptr

;   jsr initlib
; removed. this called the CONDES function

    lda #%10000000
    sta <PPU_CTRL_VAR
    sta PPU_CTRL        ;enable NMI
    lda #%00000110
    sta <PPU_MASK_VAR

waitSync3:
    lda <FRAME_CNT1
@1:
    cmp <FRAME_CNT1
    beq @1

detectNTSC:
    ldx #52             ;blargg's code
    ldy #24
@1:
    dex
    bne @1
    dey
    bne @1

    lda PPU_STATUS
    and #$80
    sta <NTSC_MODE

    jsr _ppu_off

    lda #0
    ldx #0
    jsr _set_vram_update

    ldx #<music_data
    ldy #>music_data
    lda <NTSC_MODE
    jsr FamiToneInit

    .if(FT_SFX_ENABLE)
    ldx #<sounds_data
    ldy #>sounds_data
    jsr FamiToneSfxInit
    .endif

    lda #$fd
    sta <RAND_SEED
    sta <RAND_SEED+1

    lda #0
    sta PPU_SCROLL
    sta PPU_SCROLL

    jmp _main           ;no parameters

    .include "mmc5/mmc5_macros.s"
    .include "mmc5/mmc5_cfg.s"
    .include "mmc5/bank_helpers.s"
    .include "lib/neslib.s"
    .include "lib/nesdoug.s"
    .include "music/famitone2.s"


.segment "RODATA"

music_data:
;   .include "music.s"
    .if(FT_SFX_ENABLE)
sounds_data:
;   .include "sounds.s"
    .endif


;.segment "SAMPLES"
;   .incbin "music_dpcm.bin"


.segment "VECTORS"

    .word nmi   ;$fffa vblank nmi
    .word start ;$fffc reset
    .word irq   ;$fffe irq / brk


; FIXME - the bg_test asset is too big to fit into one bank.
; .segment "CHR_00"

;   .incbin "nes_st/bg_test.chr"
