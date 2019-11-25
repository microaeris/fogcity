; MMC5 Memory Mapped Registers

; MMC5 Configuration Registers
PRG_MODE_REG            = $5100
CHR_MODE_REG            = $5101
PRG_RAM_PROTECT_1_REG   = $5102
PRG_RAM_PROTECT_2_REG   = $5103
EXTENDED_RAM_MODE_REG   = $5104
NAMETABLE_MAPPING_REG   = $5105
FILL_MODE_TILE_REG      = $5106
FILL_MODE_COLOR_REG     = $5107

; PRG Bank Switching Registers
PRG_BANK_0_REG          = $5113  ; Mode 3 $6000-$7FFF, Always RAM
PRG_BANK_1_REG          = $5114  ; Mode 3 $8000-$9FFF
PRG_BANK_2_REG          = $5115  ; Mode 3 $A000-$BFFF
PRG_BANK_3_REG          = $5116  ; Mode 3 $C000-$DFFF
PRG_BANK_4_REG          = $5117  ; Mode 3 $E000-$FFFF, Always ROM

; CHR Bank Switching Registers
CHR_BANK_0_REG          = $5120
CHR_BANK_1_REG          = $5121
CHR_BANK_2_REG          = $5122
CHR_BANK_3_REG          = $5123  ; Used in 4KiB Mode
CHR_BANK_4_REG          = $5124
CHR_BANK_5_REG          = $5125
CHR_BANK_6_REG          = $5126
CHR_BANK_7_REG          = $5127  ; Used in 4KiB Mode
CHR_BANK_8_REG          = $5128
CHR_BANK_9_REG          = $5129
CHR_BANK_A_REG          = $512A
CHR_BANK_B_REG          = $512B  ; Used in 4KiB Mode
CHR_UPPER_BANK_BITS_REG = $5130

; Vertical Split Mode Registers
VERT_SPLIT_MODE_REG     = $5200
VERT_SPLIT_SCROLL_REG   = $5201
VERT_SPLIT_BANK_REG     = $5202

; IRQ Scanline Registers
IRQ_SCANLINE_COMPARE_REG    = $5203
IRQ_SCANLINE_STATUS_REG     = $5204

; 8 x 8 Multiply Registers
MULT_16_LO_REG   = $5205
MULT_16_HI_REG   = $5206


; Constants

MAX_PRG_BANK_ID = $7E

;PRG Bankswitching Memory Types
PRG_RAM_SELECT  = $00
PRG_ROM_SELECT  = $80

; PRG Modes
PRG_MODE_0  = $0  ; One 32KB bank
PRG_MODE_1  = $1  ; Two 16KB banks
PRG_MODE_2  = $2  ; One 16KB bank and two 8KB banks
PRG_MODE_3  = $3  ; Four 8KB banks

; CHR Modes
CHR_MODE_0  = $0  ; 8KB CHR pages
CHR_MODE_1  = $1  ; 4KB CHR pages
CHR_MODE_2  = $2  ; 2KB CHR pages
CHR_MODE_3  = $3  ; 1KB CHR pages

; Nametable Mirroring Modes
NAMETABLE_HORIZ                     = $50
NAMETABLE_VERT                      = $44
NAMETABLE_DIAG                      = $14
NAMETABLE_SINGLE_SCREEN_CIRAM_0     = $00
NAMETABLE_SINGLE_SCREEN_CIRAM_1     = $55
NAMETABLE_SINGLE_SCREEN_EXRAM       = $AA
NAMETABLE_SINGLE_SCREEN_FILL_MODE   = $AA

; Extended RAM Modes
EXTENDED_RAM_MODE_NAMETABLE         = $0  ; Extra nametable (possibly for split mode)
EXTENDED_RAM_MODE_ATTRIBUTE_DATA    = $1  ; Extended attribute data (can also be used as extended nametable)
EXTENDED_RAM_MODE_RAM               = $2  ; Ordinary RAM
EXTENDED_RAM_MODE_RAM_WP            = $3  ; Ordinary RAM, write protected
