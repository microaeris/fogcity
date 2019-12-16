#include <mmc5/bank_helpers_impl.h>

#pragma bss-name(push, "ZEROPAGE")

// Every two bits represents id of a bank area.
// Only three bank areas, starting from bit 0.
// Least recently used is bits 1 and 0.
// Example: 0b XX 10 01 00
bank_area_id_t lru_bank_area;

#pragma bss-name(pop)

#pragma rodata-name ("CODE")
#pragma code-name ("CODE")

void bank_helpers_init(void)
{
    lru_bank_area = LRU_BANK_AREA_INIT;
}

bank_area_id_t choose_bank_area(uint8_t bank_id)
{
    uint8_t temp;
    bank_area_id_t bank_area_id;

    if (bank_id == PRG_BANK_1) {
        bank_area_id = PRG_BANK_AREA_1;
    } else if (bank_id == PRG_BANK_2) {
        bank_area_id = PRG_BANK_AREA_2;
    } else if (bank_id == PRG_BANK_3) {
        bank_area_id = PRG_BANK_AREA_3;
    } else {
        // Target bank not loaded, so evict least recently used bank.
        bank_area_id = (LRU_IDX_0_MASK & lru_bank_area);
    }

    // Update the LRU queue
    if (bank_area_id == GET_LRU(0)) {
        // Bank we are about to call into is first element in the queue.
        // We need to move it to the back of the queue.
        lru_bank_area >>= ID_BITS;
        lru_bank_area &= 0xCF;  // = 0b11001111 = ~LRU_IDX_2_MASK;
        lru_bank_area |= (bank_area_id << 4); // 4 = ID_BITS * 2
    } else if (bank_area_id == GET_LRU(1)) {
        temp = GET_LRU(2);
        lru_bank_area &= 0xC3;  // = 0b11000011 = ~(LRU_IDX_1_MASK | LRU_IDX_2_MASK);
        lru_bank_area |= bank_area_id << 4; // 4 = ID_BITS * 2
        lru_bank_area |= temp << 2;         // 2 = ID_BITS * 1
    }
    // else bank_area_id == GET_LRU(2), in which case the most recently used
    // item is already at the end of the list.

    return bank_area_id;
}

// TODO check that type of bank_area_id_t is a uint8_t.

void banked_call(uint8_t bank_id, void (*method)(void))
{
    bank_area_id_t bank_area_id;
    ASSERT((uint16_t)method);
    ASSERT(bank_level < MAX_BANK_DEPTH);

    bank_area_id = choose_bank_area(bank_id);
    bank_push(bank_id, bank_area_id);
    (*method)();
    bank_pop();
}

void bank_push(uint8_t bank_id, bank_area_id_t bank_area_id)
{
    bank_buffer[bank_level] = bank_id;
    ++bank_level;

    switch (bank_area_id) {
        case PRG_BANK_AREA_1: {
            set_prg_bank_1(bank_id);
            break;
        }
        case PRG_BANK_AREA_2: {
            set_prg_bank_2(bank_id);
            break;
        }
        case PRG_BANK_AREA_3: {
            set_prg_bank_3(bank_id);
            break;
        }
        default: {
            ASSERT(FALSE);
        }
    }
}

void bank_pop(void)
{
    uint8_t bank_id;
    bank_area_id_t bank_area_id;
    --bank_level;
    bank_id = bank_buffer[bank_level-1];
    bank_area_id = choose_bank_area(bank_id);

    if (bank_level > 0) {
        switch (bank_area_id) {
            case PRG_BANK_AREA_1: {
                set_prg_bank_1(bank_id);
                break;
            }
            case PRG_BANK_AREA_2: {
                set_prg_bank_2(bank_id);
                break;
            }
            case PRG_BANK_AREA_3: {
                set_prg_bank_3(bank_id);
                break;
            }
            default: {
                ASSERT(FALSE);
            }
        }

    }
}
