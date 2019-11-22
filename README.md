# Fog City

A visual novel about sentient AI, roboethics, and anime girls. 

## Dependencies 

This project depends on Python, cc65 and fceux.

`sudo apt-get install cc65 fceux`

Additionally, you will need to install the Windows version of FCEUX.

## Building

* `make` to build the game.
* `make run` to build and run the game in fceux.
* `make clean` to delete all generated files.
* `make debug` to start FCEUX and the debugger.
* `make disas` to generated the disassembled ASM. Only dumps first 64KB.

## Open Issues

* While debugging in FCEUX, after bank switching PRG memory area 3, memory area 4 loses its debug symbols. Symbols can't be reloaded and name list file is still present. 
    * TODO: Try newer version of FCEUX, file bug with FCEUX Github project, look through source for obvious issue, try with Mesen.
