# Issues

## Open

* Tests don't build. `sim6502.lib` uses up most of the zero page, leaving only 1 byte for my own variables. Linking fails with the following error.
    * To reproduce, checkout `f6fe1cdfa56ceb37fb6720c235f0dca30560aa4d` and run `make test`.

```
ld65 --target sim6502 -o build/tests/test_fog_city build/tests/test_bank_helpers.o build/tests/main.o build/tests/test_assert.o build/mmc5/bank_helpers_c.o build/bg.o build/tests/all_src_asm.o sim6502.lib
ld65: Warning: /usr/share/cc65/cfg/sim6502.cfg(6): Segment `ZEROPAGE' overflows memory area `ZP' by 3 bytes
ld65: Error: Cannot generate most of the files due to memory area overflow 
Makefile:107: recipe for target 'build/tests/test_fog_city' failed
make: *** [build/tests/test_fog_city] Error 1
```

* Test out register variables. See [Ullrich's C coding guide](https://www.cc65.org/doc/coding.html).


## Closed

* While debugging in FCEUX, after bank switching PRG memory area 3, memory area 4 loses its debug symbols. Symbols can't be reloaded and name list file is still present. 
    * TODO: Try newer version of FCEUX, file bug with FCEUX Github project, look through source for obvious issue, try with Mesen.
    * In the fceux debugger, every 0x4000 range of memory loads one name list. and my memory areas are 0x2000 bytes big. So the debugger doesn't support my use case. .
    * Switched debugger to Mesen. It supports cc65's debug symbol file out of the box! Woot!