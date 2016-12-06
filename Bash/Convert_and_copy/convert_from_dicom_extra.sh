#/bin/bash
# 03.02.16; the "convert_from_dicom.sh" script failed for the
# "missing data folder, because this folder has another data structure
# convert to nii using the regular "dcm_conv" option

# place the data in a stest folder and manually inspect before moving to
# niiRaw folder

DicomDir=/home/torgil/Projects/HUNT/SourceData/OriginalData/10_missing_fikk_2013/
niiRawDir=/home/torgil/Projects/HUNT/Testing

dcm_conv.sh -m dirName -D $DicomDir -o $niiRawDir

