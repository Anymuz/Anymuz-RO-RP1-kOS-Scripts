// Small boot script to bypass storage limits from global variables in main.ks.
WAIT UNTIL SHIP:UNPACKED.
WAIT 2.
CORE:DOEVENT("Open Terminal").
RUNPATH("0:/system/main.ks"). 