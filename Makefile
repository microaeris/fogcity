#### Macros ####

GAME_TARGET = fog_city
OUT_DIR = build
SRC_DIR = src
LIB_DIR = lib
CONFIG_FILE = cfg/mmc5.cfg
# Change this path to point to your Windows version of FCEUX.
# The Linux version of FCEUX is lacks all debugging features.
FCEUX_WIN = ~/insync/linux/nesdev/nes-tools/fceuxw/fceux.exe
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
LDFLAGS = -C $(CONFIG_FILE) -m $(OUT_DIR)/$*.map --dbgfile $(OUT_DIR)/$*.debug
# `-S` start address is 0x8000 minus space for the header.
DAFLAGS = -o $(OUT_DIR)/$(GAME_TARGET).disas --comments 4 -S 0x7FF0
NLFLAGS = -n $(GAME_TARGET) -d $(OUT_DIR)/$*.debug -c $(CONFIG_FILE) -o $(OUT_DIR)
# Select all `.c` files under the source directory
SOURCES = $(wildcard $(SRC_DIR)/*.c)
HEADERS = $(wildcard include/*.h)
GAME_PATH = $(OUT_DIR)/$(GAME_TARGET).nes
# Convert list of all `.c` source files to `.o` files in output dir.
SRCS_TO_OBJS = $(SOURCES:$(SRC_DIR)%.c=$(OUT_DIR)%.o)
NL_CONVERTER = ./tools/namelist_converter.py


#### Print debugging ####

# $(info CAFLAGS="$(CAFLAGS)")
# $(info SOURCES="$(SOURCES)")
# $(info The * is "$*")
# $(info The @ is "$@")
# $(info The < is "$<")
# $(info The ^ is "$^")
# $(info Headers is "$(HEADERS)")
# $(info Sources is "$(SOURCES)")


#### Special Built-in Targets ####

# Why is `all` a part of the phony target?
.PHONY: clean all

# Don't delete intermediate `*.o` files
.PRECIOUS: $(OUT_DIR)/%.o


#### Rules ####

all: $(GAME_PATH)

clean:
# Delete all files under ./build.
# `-f` = force
# `-v` = verbose
	@rm -fv $(OUT_DIR)/*

run: $(GAME_PATH)
	@fceux --pal 1 $<

debug: $(GAME_PATH)
	wine $(FCEUX_WIN) $<

disas: $(GAME_PATH)
	da65 $(DAFLAGS) $<

$(OUT_DIR)/crt0.o: $(SRC_DIR)/crt0.s
	ca65 $< -o $@ $(CAFLAGS)

# FIXME - We're rebuilding every source file any time any source file changes.
$(OUT_DIR)/%.o: $(SOURCES) $(HEADERS)
	cc65 -Oi $(SRC_DIR)/$*.c -o $(OUT_DIR)/$*.s $(CCFLAGS)
	ca65 $(OUT_DIR)/$*.s -o $@ $(CAFLAGS)

$(OUT_DIR)/%.nes: $(SRCS_TO_OBJS) $(OUT_DIR)/crt0.o | $(CONFIG_FILE)
# -m: Generate map file
# -C: Config file. aka ld65's linker script.
	ld65 $(LDFLAGS) -o $@ $^ nes.lib
# Generate debug symbol file for FCEUX
	python ./tools/namelist_converter.py $(NLFLAGS)
