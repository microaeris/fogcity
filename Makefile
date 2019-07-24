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
OBJS = $(wildcard $(OUT_DIR)/*.o)
HEADERS = $(wildcard include/*.h)


#### Print debugging ####

# $(info CAFLAGS="$(CAFLAGS)")
# $(info SOURCES="$(SOURCES)")


#### Special Built-in Targets ####

# Why is `all` a part of the phony target?
.PHONY: clean all

.PRECIOUS: *.o


#### Rules ####

all: $(OUT_DIR)/$(GAME_TARGET)

clean:
# Delete all files under ./build.
# `-f` = force
# `-v` = verbose
	@rm -fv $(OUT_DIR)/*

crt0.o: $(SRC_DIR)/crt0.s
	ca65 $< -o $(OUT_DIR)/$@ $(CAFLAGS)

%.o: $(SOURCES) $(HEADERS)
	$(info The star is "$*")
	$(info The at is "$@")
	$(info Headers is "$(HEADERS)")
	$(info Sources is "$(SOURCES)")
	cc65 -Oi $< -o $*.s $(CCFLAGS)
	ca65 $*.s -o $@ $(CAFLAGS)

%.nes: $(OBJS) $(OUT_DIR)/crt0.o
	ld65 -C $(SRC_DIR)/nrom_32k_vert.cfg -o $@ $^ nes.lib
