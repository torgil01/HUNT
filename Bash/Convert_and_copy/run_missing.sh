#/bin/bash
# 25.02.16 hunt_2009_12 was not converted??



OrigDataDir=/home/torgil/Projects/HUNT/SourceData/OriginalData/hunt_2009_12
niiRawDir=/home/torgil/Projects/HUNT/SourceData/NiiRaw_dcm2nii/hunt_2009_12

dcm_conv.sh -m hunt -D $OrigDataDir -o $niiRawDir


