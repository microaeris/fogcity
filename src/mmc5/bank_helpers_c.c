#pragma rodata-name ("CODE")
#pragma code-name ("CODE")

#include <src/mmc5/bank_helpers_impl.h>


void banked_call(unsigned char bankId, void (*method)(void))
{
    ASSERT((uint16_t)method);
    ASSERT(bankLevel < MAX_BANK_DEPTH);

    if ((bankId != PRG_BANK_1) &&
        (bankId != PRG_BANK_2) &&
        (bankId != PRG_BANK_3)) {
        // Target bank not loaded, so evict least recently used bank.
    }

    bank_push(bankId);
    (*method)();
    bank_pop();
}

void bank_push(unsigned char bankId)
{
    bankBuffer[bankLevel] = bankId;
    ++bankLevel;
    // set_prg_bank(bankId);
}

void bank_pop(void)
{
    --bankLevel;
    if (bankLevel > 0) {
        // set_prg_bank(bankBuffer[bankLevel-1]);
    }
}
