# Issues

## Open

* None

## Closed

* While debugging in FCEUX, after bank switching PRG memory area 3, memory area 4 loses its debug symbols. Symbols can't be reloaded and name list file is still present. 
    * TODO: Try newer version of FCEUX, file bug with FCEUX Github project, look through source for obvious issue, try with Mesen.
    * In the fceux debugger, every 0x4000 range of memory loads one name list. and my memory areas are 0x2000 bytes big. So the debugger doesn't support my use case. .
    * Switched debugger to Mesen. It supports cc65's debug symbol file out of the box! Woot!