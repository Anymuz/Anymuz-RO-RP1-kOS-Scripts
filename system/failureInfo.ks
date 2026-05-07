// 0:/system/failureInfo.ks
// Shown by loadShip.ks when no script matches the current vessel name.

CLEARSCREEN.
PRINT "================================================================".
PRINT " BOOT FAILED: no script matches vessel name '" + SHIP:NAME + "'.".
PRINT "================================================================".
skipLine().

PRINT "Naming convention:".
PRINT "  Series vessels:    <Series>-<Variant>".
PRINT "    Example:         Bereshit-R1   ->  0:/ships/bereshit/Bereshit-R1.ks".
PRINT "  Single vessels:    <Name>  (no dash)".
PRINT "    Example:         Probe1        ->  0:/ships/Probe1.ks".
skipLine().

PRINT "Checks:".
PRINT "  1. Vessel name in the editor matches the script filename exactly (case-sensitive).".
PRINT "  2. The script file exists at the path above.".
PRINT "  3. For series vessels, the folder name is the lowercased series prefix.".
skipLine().

PRINT "Recover: rename the vessel or add the script, then reboot the kOS CPU.".
PRINT "================================================================".
