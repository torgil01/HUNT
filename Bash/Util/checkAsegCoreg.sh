#!/bin/bash
# The aseg.mgz is coregistered to brain_t1w
# check that coreg is good by calculating dice overlap
# between spm_wm_mask  and aseg_wm_mask 



#imDir=/home/torgil/Projects/HUNT/Testing/wmh_mask/data/
imDir=/home/torgil/Projects/HUNT/WorkData
startDir=`pwd`
asegFileName=fsAseg.nii.gz

# find all the warps in $imDir
asegFiles=(`find $imDir -name $asegFileName`)
for aseg in ${asegFiles[@]}; do    
    currentDir=`dirname ${aseg}`
    dm1=`dirname ${currentDir}` # T1
    thisStudy=`dirname ${dm1}` # id
    id=`basename $thisStudy`
    spmGm=${currentDir}/../c1t1w.nii.gz
    if [ -e $spmGm ]; then
	tmpdir=`mktemp -d`
	fsGmMask=${tmpdir}/fs_gm.nii.gz
	spmGmMask=${tmpdir}/spm_gm.nii.gz
	lGM=${tmpdir}/left_fs_gm.nii.gz
	rGM=${tmpdir}/right_fs_gm.nii.gz
	#lCGM=${tmpdir}/left_cereb_fs_gm.nii.gz	
	#rCGM=${tmpdir}/right_cereb_fs_gm.nii.gz
	lOthr1=${tmpdir}/left_othr1_fs_gm.nii.gz
	lOthr2=${tmpdir}/left_othr2_fs_gm.nii.gz
	rOthr=${tmpdir}/right_othr_fs_gm.nii.gz	
	diceOutput=${tmpdir}/dice.txt
	# make binary wm mask of FS seg
	fslmaths ${aseg} -thr 3  -uthr 3 -bin ${lGM}  &
	fslmaths ${aseg} -thr 42 -uthr 42  -bin ${rGM}  &  
	fslmaths ${aseg} -thr 8  -uthr 13  -bin ${lOthr1} & 
	fslmaths ${aseg} -thr 17 -uthr 20  -bin ${lOthr2} &
	fslmaths ${aseg} -thr 47 -uthr 56  -bin ${rOthr} &
	wait
	
	fslmaths ${lGM} -add ${rGM} -add ${lOthr1} -add ${lOthr2} -add ${rOthr} -bin  $fsGmMask  &
	fslmaths ${spmGm} -thr 0.9 -bin  $spmGmMask &
	wait
	ImageMath 3 $diceOutput DiceAndMinDistSum $spmGmMask $fsGmMask
	printf "%s" $id
	cat $diceOutput
	rm -rf $tmpdir &
    fi
done
cd $startDir




