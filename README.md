# croslockshutdown
A program written in C that on specific cros devices (chromebooks) with Arch Linux installed, allows for the screenlock key to instead shut down the system after ~3 seconds.

# Running CLSD
1. Run gcc powerkey
2. Run sudo ./a.out

# Installing CLSD
1. Run make
2. Run sudo make install

# Installing CLSD with expert-lamp
1. Run sudo expert-lamp install croslockshutdown

The only dependency is gcc. 

(WARNING, this has only been tested on one device, so expect mixed results unless using a Dragonair x360).
