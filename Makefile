#### Macros ####

GAME_TARGET = fog_city
OUT_DIR = build
SRC_DIR = src
LIB_DIR = lib
TEST_DIR = tests
CONFIG_FILE = cfg/mmc5.cfg
MESEN = ~/insync/linux/nesdev/nes-tools/Mesen.exe
# Include directories separated by colons
IDIR = include:.:src
# Create a list of strings from IDIR and prepend all items with `-I`
IFLAGS = $(patsubst %,-I%,$(subst :, ,$(IDIR)))
# Debug info generation is always on. Since the generated debug info is not
# appended to the generated executables, it is a good idea to always use -g.
# It makes the object files and libraries slightly larger (~30%), but this is
# usually not a problem. https://www.cc65.org/doc/debugging-3.html
CAFLAGS = $(IFLAGS) -g
CCFLAGS = -Oi --add-source $(IFLAGS) -g
LDFLAGS = -C $(CONFIG_FILE) -m $(OUT_DIR)/$*.map --dbgfile $(OUT_DIR)/$*.dbg
# -S` start address is 0x8000 minus space for the header.
DAFLAGS = -o $(OUT_DIR)/$(GAME_TARGET).disas --comments 4 -S 0x7FF0
HEADERS = $(wildcard include/*.h)
# Select all `.c` files under the source directory recursively
SOURCES_TEMP = $(wildcard $(SRC_DIR)/**/*.c) $(wildcard $(SRC_DIR)/*.c)
SOURCES = $(filter-out $(SRC_DIR)/$(TEST_DIR)/%, $(SOURCES_TEMP))
OBJECTS = $(SOURCES:$(SRC_DIR)%.c=$(OUT_DIR)%.o)
ASM_SOURCES = $(wildcard $(SRC_DIR)/*.s) $(wildcard $(SRC_DIR)/**/*.s)
ASM_OBJECTS = $(ASM_SOURCES:$(SRC_DIR)%.s=$(OUT_DIR)%.o)
GAME_PATH = $(OUT_DIR)/$(GAME_TARGET).nes

# Variables to build tests

TEST_OUT_DIR = $(OUT_DIR)/$(TEST_DIR)
TEST_SRC = $(wildcard $(SRC_DIR)/$(TEST_DIR)/*.c) $(wildcard $(SRC_DIR)/$(TEST_DIR)/**/*.c)
TEST_SRC_TO_ASM = $(TEST_SRC:$(SRC_DIR)/%.c=$(OUT_DIR)/%.s)
TEST_SRC_TO_OBJ = $(TEST_SRC:$(SRC_DIR)/%.c=$(OUT_DIR)/%.o)
TEST_ASM_TO_OBJ = $(TEST_SRC_TO_ASM:%.s=%.o)
GAME_ASM = $(SRC_DIR)/$(TEST_DIR)/all_src_asm.s
GAME_ASM_TO_OBJ = $(GAME_ASM:$(SRC_DIR)%.s=$(OUT_DIR)%.o)
GAME_OBJ_FILTERED = $(filter-out $(OUT_DIR)/assert.o $(OUT_DIR)/main.o, $(OBJECTS))
TEST_AND_GAME_OBJ = $(GAME_ASM_TO_OBJ_FILTERED) $(TEST_ASM_TO_OBJ) $(GAME_OBJ_FILTERED)
TEST_BINARY = $(OUT_DIR)/$(TEST_DIR)/test_$(GAME_TARGET)
TEST_CCFLAGS = $(CCFLAGS) --target sim6502
TEST_LDFLAGS = --target sim6502


#### Special Built-in Targets ####

# Why is `all` a part of the phony target?
.PHONY: clean all

# Don't delete intermediate `*.o` files
.PRECIOUS: $(OUT_DIR)/%.o $(OUT_DIR)/%.s


#### Rules ####

all: $(GAME_PATH)

clean:
# -f` = force, `-v` = verbose, `-r` = recursive
	@rm -rfv $(OUT_DIR)/*

run: $(GAME_PATH)
	mono $(MESEN) $< --region PAL

disas: $(GAME_PATH)
	da65 $(DAFLAGS) $<

test: $(GAME_PATH) $(TEST_BINARY)
	sim65 -v $(TEST_BINARY)

$(OUT_DIR)/crt0.o: $(SRC_DIR)/crt0.s
	ca65 $< -o $@ $(CAFLAGS)

# TODO
# Project not being rebuilt when changing ASM files.
# Try using $? instead of $^ to select only prerequisites newer than target.
# We're rebuilding every source file any time any source file changes.

$(OUT_DIR)/%.o: $(SOURCES) $(HEADERS) force
	cc65 $(SRC_DIR)/$*.c -o $(OUT_DIR)/$*.s $(CCFLAGS)
	ca65 $(OUT_DIR)/$*.s -o $(OUT_DIR)/$*.o $(CAFLAGS)

$(OUT_DIR)/%.nes: $(OBJECTS) $(OUT_DIR)/crt0.o | $(CONFIG_FILE)
# -m: Generate map file
# -C: Config file. aka ld65's linker script.
	ld65 $(LDFLAGS) -o $@ $^ nes.lib


#### Testing ####

$(TEST_OUT_DIR)/%.s: $(TEST_SRC) force
	cc65 $(SRC_DIR)/$(TEST_DIR)/$*.c -o $(TEST_OUT_DIR)/$*.s $(TEST_CCFLAGS)

$(TEST_ASM_TO_OBJ): $(TEST_SRC_TO_ASM) force
	ca65 $*.s -o $*.o $(CAFLAGS)

$(GAME_ASM_TO_OBJ): $(GAME_ASM) force
	ca65 $(patsubst $(OUT_DIR)%,$(SRC_DIR)%,$*).s -o $*.o $(CAFLAGS)

$(TEST_BINARY): $(TEST_AND_GAME_OBJ) $(GAME_ASM_TO_OBJ)
	ld65 $(TEST_LDFLAGS) -o $@ $^ sim6502.lib


#### Hacks ####

# This dir needs to exist for cc65 to be able to output files to it.
# Git ignore currently ignores everything under build, so I don't commit this
# directory. So instead, let's make this directory when we need it.
force:
	@mkdir $(OUT_DIR)/mmc5 -p
	@mkdir $(TEST_OUT_DIR) -p
