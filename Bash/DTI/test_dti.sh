
baseDir=/home/torgil/Projects/HUNT/DTI_testing

for dirs in ${baseDir}/*
do
    dtiDir=${dirs}/DTI
    if [ -d "$dtiDir" ]
    then
	in=${dtiDir}/dti.nii.gz
	out=${dtiDir}/dt
	bval=${dtiDir}/dti.bval
	bvec=${dtiDir}/dti.bvec
	bash fslDti.sh -i $in -v $bvec -b $bval -o $out 
    fi           
done




