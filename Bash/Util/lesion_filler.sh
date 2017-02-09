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
while getopts "hd:w:t:f:m:a:" flag
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
    a)
	aseg=$OPTARG
	;;
    h|?)
      echo $flag
      usage
      exit 2
      ;;
  esac
done

cd ${t1AntsDir}
lesionMask=${t1AntsDir}/lesionMask.nii.gz
tmpImg=${t1AntsDir}/tmp1.nii.gz
lesionMaskInfo=${t1AntsDir}/lesionMask.info
# 4 possible cases
# case 1 wmh and aseg
if [ -e ${aseg} ] && [ -e ${wmh} ] ; then
    tmp2Img=${t1AntsDir}/tmp2.nii.gz
    tmp3Img=${t1AntsDir}/tmp3.nii.gz
    tmp4Img=${t1AntsDir}/tmp4.nii.gz
    hypo=${t1AntsDir}/fsHypointensities.nii.gz
    lWM=${t1AntsDir}/lWM.nii.gz
    rWM=${t1AntsDir}/rWM.nii.gz
    wm=${t1AntsDir}/wmMask.nii.gz
    # cut the wmh with a wm mask so that no part of the lesion mask is outside wm
    # SPM wm segmentation is unreliable here, so we assemble a wm mask from FS aseg file
    # wmMask = leftWM + rightWM + wmHypo = labels (2 + 41 + 77)
    ${FSL_BIN}/fslmaths ${aseg} -uthr 41 -thr 41 -bin ${rWM}
    ${FSL_BIN}/fslmaths ${aseg} -uthr 2 -thr 2 -bin ${lWM}
    ${FSL_BIN}/fslmaths ${aseg} -uthr 77 -thr 77 -bin ${hypo}
    ${FSL_BIN}/fslmaths ${hypo} -add ${lWM} -add ${rWM}  ${wm}            
    # smooth wmh (tmp2Imag is output there  
    ${ANTSPATH}/ImageMath 3 ${tmp2Img} G ${wmh} 1.5
    # add hypo mask    
    ${FSL_BIN}/fslmaths ${tmp2Img} -add ${hypo} ${tmpImg}
    # add threshold   
    ${FSL_BIN}/fslmaths  ${tmpImg} -thr 0.15 -bin  ${tmp3Img}
    # cut non wm parts of lesion mask 
    ${FSL_BIN}/fslmaths  ${tmp3Img} -mul ${wm} ${tmp4Img}
    # but this is not perfect, so we add the non-smoothed wmh mask
    ${FSL_BIN}/fslmaths  ${tmp4Img} -add ${wmh} -thr 0.9 -bin  ${lesionMask}
    rm ${tmp2Img} ${tmpImg} ${tmp3Img} ${tmp4Img} ${rWM} ${lWM} ${wm}
    echo "lesion mask created with aseg + wmh" >  $lesionMaskInfo
fi
# case 2 wmh only
if [ ! -e ${aseg} ] && [ -e ${wmh} ] ; then
    tmp2Img=${t1AntsDir}/tmp2.nii.gz
    tmp3Img=${t1AntsDir}/tmp3.nii.gz
    hypo=${t1AntsDir}/fsHypointensities.nii.gz
    lWM=${t1AntsDir}/lWM.nii.gz
    rWM=${t1AntsDir}/rWM.nii.gz
    wm=${t1AntsDir}/wmMask.nii.gz
    # cut the wmh with a wm mask so that no part of the lesion mask is outside wm
    # SPM wm segmentation is unreliable here, so we assemble a wm mask from FS aseg file
    # wmMask = leftWM + rightWM + wmHypo = labels (2 + 41 + 77)
    ${FSL_BIN}/fslmaths ${aseg} -uthr 41 -thr 41 -bin ${rWM}
    ${FSL_BIN}/fslmaths ${aseg} -uthr 2 -thr 2 -bin ${lWM}
    ${FSL_BIN}/fslmaths ${aseg} -uthr 77 -thr 77 -bin ${hypo}
    ${FSL_BIN}/fslmaths ${hypo} -add ${lWM} -add ${rWM}  ${wm}            
    # smooth wmh mask
    ${ANTSPATH}/ImageMath 3 ${tmpImg} G ${wmh} 1.5
    ${FSL_BIN}/fslmaths  ${tmpImg} -thr 0.1.5 -bin  ${tmp2Img}
    # cut non wm parts of lesion mask 
    ${FSL_BIN}/fslmaths  ${tmp2Img} -mul ${wm} ${tmp3Img}
    # but this is not perfect, so we add the non-smoothed wmh mask
    ${FSL_BIN}/fslmaths  ${tmp3Img} -add ${wmh} -thr 0.9 -bin  ${lesionMask}
    rm ${tmp2Img} ${tmpImg} ${tmp3Img} ${rWM} ${lWM}  ${wm}
    echo "lesion mask created with wmh" >  $lesionMaskInfo
fi
# case 3 aseg only
if [ -e ${aseg} ] && [ ! -e ${wmh} ] ; then
    hypo=${t1AntsDir}/fsHypointensities.nii.gz	
    ${FSL_BIN}/fslmaths ${aseg} -uthr 77 -thr 77 -bin ${hypo}
    cp $hypo  $lesionMask
    echo "lesion mask created with aseg" >  $lesionMaskInfo
fi
# case 4 none (we should not get here)
if [ ! -e ${aseg} ] && [ ! -e ${wmh} ] ; then
    exit 0
fi

    
# make T1 image w. lesions filled
t1Filled=${t1AntsDir}/brain_lesionFilled.nii.gz
    

# add wmh to wm seg using FSL lesion_filling 
${FSL_BIN}/lesion_filling -i ${t1File}\
	       -o ${t1Filled}\
	       -l ${lesionMask}\
	       -w ${wmMask}
# cleanup
rm ${t1AntsDir}/brain_lesionFilled_inneronly.nii.gz
