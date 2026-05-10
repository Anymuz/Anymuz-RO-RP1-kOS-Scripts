// The R2 is modified from R1 to carry a 75L sounding  payload above  100km, although it is longer with different tail fins.
// Due to the dynamic nature of the software, the R1 script will adapt via the bereshit.ks program script as it has same engienes and fuel type.
// It has four boosters but the R1 script will adapt as all libraries are designed this way, so this is why only one  line is needded here:abort
logMessage("Booting Bereshit R1 script, as it adapts for R2 configuration.", "system", TRUE, FALSE, TRUE).
RUNPATH("0:/ships/bereshit/Bereshit-R1.ks").