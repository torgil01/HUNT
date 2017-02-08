#!/bin/bash
# lesion filling script
# Input:
# -d $t1AntsDir
# -w $wmh
# -t $t1File
# -f $t1Filled
# -m $wmMask

export ANTSPATH=/usr/share/ANTS
export FSL_BIN=/usr/share/fsl/5.0/bin
source /etc/fsl/5.0/fsl.sh


# parse args
while getopts "hd:w:t:f:m:" flag
do
  case "$flag" in
    d)
	t1AntsDir=$OPTARG	
      ;;
    w)
	wmh=$OPTARG
      ;;
    t)
	t1File=$OPTARG
      ;;
    f)
      t1Filled=$OPTARG
      ;;	
    m)
      wmMask=$OPTARG
      ;;
    h|?)
      echo $flag
      usage
      exit 2
      ;;
  esac
done


cd ${t1AntsDir}
maskSmoothedWMH=${t1AntsDir}/wmh_sigma1.nii.gz
tmpImg=${t1AntsDir}/wmh_sigma1-tmp.nii.gz

aseg=${t1AntsDir}/fsAseg.nii.gz # aseg.mgz from freesurfer 
if [ -e ${aseg} ]; then
    tmp2Img=${t1AntsDir}/aseg_tmp.nii.gz
    hypo=${t1AntsDir}/fsHypointensities.nii.gz	
    ${FSL_BIN}/fslmaths ${aseg} -uthr 77 -thr 77 -bin ${hypo}
    ${FSL_BIN}/fslmaths ${wmh} -add ${hypo} ${tmp2Img}
    ${ANTSPATH}/ImageMath 3 ${tmpImg} G ${tmp2Img} 1
    rm ${tmp2Img}
else
    ${ANTSPATH}/ImageMath 3 ${tmpImg} G ${wmh} 1
fi

# Binarize w. fslmaths
${FSL_BIN}/fslmaths  ${tmpImg} -thr 0.2 -bin  ${maskSmoothedWMH}

# cleanup
rm ${tmpImg}

    
# make T1 image w. lesions filled
t1Filled=${t1AntsDir}/brain_lesionFilled.nii.gz
    

# add wmh to wm seg uing FSL lesion_filling 
${FSL_BIN}/lesion_filling -i ${t1File}\
	       -o ${t1Filled}\
	       -l ${maskSmoothedWMH}\
	       -w ${wmMask}
# cleanup
rm ${t1AntsDir}/brain_lesionFilled_inneronly.nii.gz
