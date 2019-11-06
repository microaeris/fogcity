#!usr/bin/python

CHR_FORMAT = "CHR_%02X: start = $0000, size = $1000, file = %%O, fill = yes;"
SEGMENT_CHR_FORMAT = "CHR_%02X:   load = CHR_%02X,         type = ro;"
SEGMENT_BANK_FORMAT = "BANK_%02X:  load = PRG_BS,  align = $2000, type = ro,  \
define = yes;"
DECLARE_PRG_SEGMENT = ".segment \"BANK_%02X\""

# Minus one to account for the static PRG bank
NUM_PRG_BANKS = 128 - 1
NUM_CHR_BANKS = 256
# MMC5 PRG Mode 3 start addresses
PRG_START_ADDRESS = [
    0x8000,
    0xA000,
    0xC000
]
NUM_PRG_ROM_BANKS = 3


def main():
    '''Output linker script memory sections to stdout.
    '''
    for i in range(NUM_CHR_BANKS):
        print(CHR_FORMAT % i)

    for i in range(NUM_CHR_BANKS):
        print(SEGMENT_CHR_FORMAT % (i, i))

    for i in range(NUM_PRG_BANKS):
        print(SEGMENT_BANK_FORMAT % i)

    for i in range(NUM_PRG_BANKS):
        print(DECLARE_PRG_SEGMENT % i)


if __name__ == '__main__':
    main()
