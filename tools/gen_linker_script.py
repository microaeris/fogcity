#!usr/bin/python

PRG_FORMAT = "PRG_%02X: start = $%X, size = $2000, file = %%O, fill = yes, \
define = yes;"
CHR_FORMAT = "CHR_%02X: start = $0000, size = $1000, file = %%O, fill = yes;"
SEGMENT_CHR_FORMAT = "CHR_%02X:   load = CHR_%02X,         type = ro;"
SEGMENT_BANK_FORMAT = "BANK_%02X:  load = PRG_%02X,         type = ro,  \
define = yes;"

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
    for i in range(NUM_PRG_BANKS):
        # Since there are 127 switchable PRG banks, and only three banking
        # slots to assign them to, one slot will have an extra bank that can be
        # assigned to it. That is, the bank that starts at 0xC000 will have an
        # extra bank that can be mapped to it.
        start_addr_idx = min(i / (NUM_PRG_BANKS / NUM_PRG_ROM_BANKS),
                             NUM_PRG_ROM_BANKS - 1)
        start_addr = PRG_START_ADDRESS[start_addr_idx]
        print(PRG_FORMAT % (i, start_addr))

    for i in range(NUM_CHR_BANKS):
        print(CHR_FORMAT % i)

    for i in range(NUM_CHR_BANKS):
        print(SEGMENT_CHR_FORMAT % (i, i))

    for i in range(NUM_PRG_BANKS):
        print(SEGMENT_BANK_FORMAT % (i, i))


if __name__ == '__main__':
    main()
