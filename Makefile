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
# OBJS = $(wildcard $(OUT_DIR)/*.o)
HEADERS = $(wildcard include/*.h)
GAME_PATH = $(OUT_DIR)/$(GAME_TARGET)


#### Print debugging ####

# $(info CAFLAGS="$(CAFLAGS)")
# $(info SOURCES="$(SOURCES)")


#### Special Built-in Targets ####

# Why is `all` a part of the phony target?
.PHONY: clean all

.PRECIOUS: *.o


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

%.o: $(SOURCES) $(HEADERS)
	cc65 -Oi $< -o $(SOURCES:$(SRC_DIR)%.c=$(OUT_DIR)%.s) $(CCFLAGS)
	ca65 $(SOURCES:$(SRC_DIR)%.c=$(OUT_DIR)%.s) -o $(SOURCES:$(SRC_DIR)%.c=$(OUT_DIR)%.o) $(CAFLAGS)

$(OUT_DIR)/%.nes: $(SOURCES:$(SRC_DIR)%.c=$(OUT_DIR)%.o) $(OUT_DIR)/crt0.o
# $(info The * is "$*")
# $(info The @ is "$@")
# $(info The < is "$<")
# $(info The ^ is "$^")
# $(info Headers is "$(HEADERS)")
# $(info Sources is "$(SOURCES)")
	ld65 -C $(SRC_DIR)/nrom_32k_vert.cfg -o $@ $^ nes.lib
