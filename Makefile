#### Macros ####

GAME_TARGET = fog_city
OUT_DIR = build
SRC_DIR = src
LIB_DIR = lib
CONFIG_FILE = cfg/mmc5.cfg
MESEN = ~/insync/linux/nesdev/nes-tools/Mesen.exe
# Include directories separated by colons
IDIR = include:.
# Create a list of strings from IDIR and prepend all items with `-I`
IFLAGS = $(patsubst %,-I%,$(subst :, ,$(IDIR)))
# Debug info generation is always on. Since the generated debug info is not
# appended to the generated executables, it is a good idea to always use -g.
# It makes the object files and libraries slightly larger (~30%), but this is
# usually not a problem. https://www.cc65.org/doc/debugging-3.html
CAFLAGS = $(IFLAGS) -g
CCFLAGS = -Oi --add-source $(IFLAGS) -g
LDFLAGS = -C $(CONFIG_FILE) -m $(OUT_DIR)/$*.map --dbgfile $(OUT_DIR)/$*.dbg
# `-S` start address is 0x8000 minus space for the header.
DAFLAGS = -o $(OUT_DIR)/$(GAME_TARGET).disas --comments 4 -S 0x7FF0
# Select all `.c` files under the source directory recursively
SOURCES = $(wildcard $(SRC_DIR)/**/*.c) $(wildcard $(SRC_DIR)/*.c)
ASM_SOURCES = $(wildcard $(SRC_DIR)/*.s) $(wildcard $(SRC_DIR)/**/*.s)
HEADERS = $(wildcard include/*.h)
OBJECTS = $(SOURCES:$(SRC_DIR)%.c=$(OUT_DIR)%.o)
GAME_PATH = $(OUT_DIR)/$(GAME_TARGET).nes

# Variables to build tests
TEST_DIR = tests
TEST_SOURCES = $(wildcard $(TEST_DIR)/*.c) $(wildcard $(TEST_DIR)/**/*.c)
TEST_OBJECTS = $(TEST_SOURCES:%.c=$(OUT_DIR)/%.o)
TEST_BINARY = $(OUT_DIR)/$(TEST_DIR)/test_$(GAME_TARGET)
TEST_CCFLAGS = $(CCFLAGS) --target sim6502
TEST_LDFLAGS = --target sim6502
# Assert is mocked out in our tests. Test has its own main.
SOURCES_TO_TEST = $(filter-out $(SRC_DIR)/assert.c $(SRC_DIR)/main.c, $(SOURCES))
OBJECTS_TO_TEST = $(filter-out $(OUT_DIR)/assert.o $(OUT_DIR)/main.o, $(OBJECTS))


#### Print debugging ####

# $(info CAFLAGS="$(CAFLAGS)")
# $(info SOURCES="$(SOURCES)")
# $(info The * is "$*")
# $(info The @ is "$@")
# $(info The < is "$<")
# $(info The ^ is "$^")
# $(info Headers is "$(HEADERS)")
# $(info Sources is "$(SOURCES)")
# $(info ASM Sources is "$(ASM_SOURCES)")
# $(info Object files is "$(OBJECTS)")
# $(info SOURCES_TO_TEST is "$(SOURCES_TO_TEST)")
# $(info OBJECTS_TO_TEST is "$(OBJECTS_TO_TEST)")


#### Special Built-in Targets ####

# Why is `all` a part of the phony target?
.PHONY: clean all

# Don't delete intermediate `*.o` files
.PRECIOUS: $(OUT_DIR)/%.o


#### Rules ####

all: $(GAME_PATH)

clean:
# Delete all files under ./build.
# `-f` = force, `-v` = verbose, `-r` = recursive
	@rm -rfv $(OUT_DIR)/*

run: $(GAME_PATH)
	mono $(MESEN) $< --region PAL

disas: $(GAME_PATH)
	da65 $(DAFLAGS) $<

test: $(TEST_BINARY)
	sim65 -v $(TEST_BINARY)

$(OUT_DIR)/crt0.o: $(SRC_DIR)/crt0.s
	ca65 $< -o $@ $(CAFLAGS)

# TODO
# project not being rebuilt when changing ASM files.

# FIXME - We're rebuilding every source file any time any source file changes.
$(OUT_DIR)/%.o: $(SOURCES) $(HEADERS)
# Ugly hacks. This dir needs to exist for cc65 to be able to output files to it.
# Git ignore currently ignores everything under build, so I don't commit this directory
# So instead, let's make this directory when we need it.
	@mkdir $(OUT_DIR)/mmc5 -p
	cc65 $(SRC_DIR)/$*.c -o $(OUT_DIR)/$*.s $(CCFLAGS)
	ca65 $(OUT_DIR)/$*.s -o $(OUT_DIR)/$*.o $(CAFLAGS)

$(OUT_DIR)/%.nes: $(OBJECTS) $(OUT_DIR)/crt0.o | $(CONFIG_FILE)
# -m: Generate map file
# -C: Config file. aka ld65's linker script.
	ld65 $(LDFLAGS) -o $@ $^ nes.lib

# All test artifacts can be found under `build/tests`
# FIXME - why are all of my makefile rules so ugly?
$(OUT_DIR)/$(TEST_DIR)/%.o: $(TEST_SOURCES) $(SOURCES_TO_TEST)
	@mkdir $(OUT_DIR)/$(TEST_DIR) -p
	cc65 $(TEST_DIR)/$*.c -o $(OUT_DIR)/$(TEST_DIR)/$*.s $(TEST_CCFLAGS)
	ca65 $(OUT_DIR)/$(TEST_DIR)/$*.s -o $(OUT_DIR)/$(TEST_DIR)/$*.o $(CAFLAGS)

$(TEST_BINARY): $(TEST_OBJECTS) $(OBJECTS_TO_TEST)
	ld65 $(TEST_LDFLAGS) -o $@ $^ sim6502.lib
