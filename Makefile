#### Macros ####

GAME_TARGET = fog_city.nes
OUT_DIR = build
SRC_DIR = src
LIB_DIR = lib
# Include directories separated by colons
IDIR = include:.
# Create a list of strings from IDIR and prepend all items with `-I`
IFLAGS = $(patsubst %,-I%,$(subst :, ,$(IDIR)))
CAFLAGS = $(IFLAGS)
CCFLAGS = --add-source $(IFLAGS)
# Select all `.c` files under the source directory
SOURCES = $(wildcard $(SRC_DIR)/*.c)
HEADERS = $(wildcard include/*.h)
GAME_PATH = $(OUT_DIR)/$(GAME_TARGET)
# Convert list of all `.c` source files to `.o` files in output dir.
SRCS_TO_OBJS = $(SOURCES:$(SRC_DIR)%.c=$(OUT_DIR)%.o)


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

$(OUT_DIR)/crt0.o: $(SRC_DIR)/crt0.s
	ca65 $< -o $@ $(CAFLAGS)

# FIXME - We're rebuilding every source file any time any source file changes.
$(OUT_DIR)/%.o: $(SOURCES) $(HEADERS)
	cc65 -Oi $(SRC_DIR)/$*.c -o $(OUT_DIR)/$*.s $(CCFLAGS)
	ca65 $(OUT_DIR)/$*.s -o $@ $(CAFLAGS)

$(OUT_DIR)/%.nes: $(SRCS_TO_OBJS) $(OUT_DIR)/crt0.o
	ld65 -C $(SRC_DIR)/nrom_32k_vert.cfg -o $@ $^ nes.lib
