# Intel's Software developmenet Emulator for X86 Commands
# SDE Knobs https://www.intel.com/content/www/us/en/developer/articles/tool/software-development-emulator.html
# Get SDE Help
sde -help -long

#  list all dynamic instructions that are executed along with instruction length, instruction category, and ISA extension grouping
 sde.exe -mix -- ./test.o

# Debug with sde along with gdb

# debug Trace, restrict to range of address 
sde -start_address=0x0FFF000 -stop_address=0x0FFFF0FF -debugtrace  -- ./test.o
# chip check, restrict to specific exe, dll
sde -spr -chip-check -- ./test.o
# Accouting
# Avx 2 SEE transitions
# Emulate and Debug code
# Check Alignment on data
