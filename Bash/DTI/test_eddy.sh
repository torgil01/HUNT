
baseDir=/home/torgil/Projects/HUNT/Testing2/9410000000053/DTI/
in=${baseDir}/dti.nii.gz
out=${baseDir}/corr_es05.nii.gz
mask=${baseDir}/brain_mask.nii.gz
bval=${baseDir}/dti.bval
bvec=${baseDir}/dti.bvec
es=0.05

#bash doEddy.sh -i $in -o $out -m $mask -v $bvec -b $bval -e $es

bash doEddy.sh -i $in -o $out -m $mask -v $bvec -b $bval -e $es
