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
CCFLAGS = --add-source $(IFLAGS) -g
LDFLAGS = -C $(CONFIG_FILE) -m $(OUT_DIR)/$*.map --dbgfile $(OUT_DIR)/$*.dbg
# `-S` start address is 0x8000 minus space for the header.
DAFLAGS = -o $(OUT_DIR)/$(GAME_TARGET).disas --comments 4 -S 0x7FF0
# Select all `.c` files under the source directory recursively
SOURCES = $(wildcard $(SRC_DIR)/**/*.c) $(wildcard $(SRC_DIR)/*.c)
HEADERS = $(wildcard include/*.h)
OBJECTS = $(SOURCES:$(SRC_DIR)%.c=$(OUT_DIR)%.o)
GAME_PATH = $(OUT_DIR)/$(GAME_TARGET).nes


#### Print debugging ####

# $(info CAFLAGS="$(CAFLAGS)")
# $(info SOURCES="$(SOURCES)")
# $(info The * is "$*")
# $(info The @ is "$@")
# $(info The < is "$<")
# $(info The ^ is "$^")
# $(info Headers is "$(HEADERS)")
# $(info Sources is "$(SOURCES)")
# $(info Object files is "$(OBJECTS)")


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

# TODO: Add unit tests
# test:
# 	sim65

$(OUT_DIR)/crt0.o: $(SRC_DIR)/crt0.s
	ca65 $< -o $@ $(CAFLAGS)

# FIXME - We're rebuilding every source file any time any source file changes.
$(OUT_DIR)/%.o: $(SOURCES) $(HEADERS)
# Ugly hacks. This dir needs to exist for cc65 to be able to output files to it.
# Git ignore currently ignores everything under build, so I don't commit this directory
# So instead, let's make this directory when we need it.
	@mkdir $(OUT_DIR)/mmc5 -p
	cc65 -Oi $(SRC_DIR)/$*.c -o $(OUT_DIR)/$*.s $(CCFLAGS)
	ca65 $(OUT_DIR)/$*.s -o $(OUT_DIR)/$*.o $(CAFLAGS)

$(OUT_DIR)/%.nes: $(OBJECTS) $(OUT_DIR)/crt0.o | $(CONFIG_FILE)
# -m: Generate map file
# -C: Config file. aka ld65's linker script.
	ld65 $(LDFLAGS) -o $@ $^ nes.lib
