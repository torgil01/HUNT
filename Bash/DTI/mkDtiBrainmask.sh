#!/bin/bash
# elaborate way to make dti mask 
# 

function usage {
  echo "elaborate way to make dti brainmask"
  echo "Usage:  "
  echo "$0  -i dti_image_stack -b bval_file -m mask_base_name"
}


# parse args
while getopts "i:b:m:" flag
do
  case "$flag" in
    i)
      dtiVol=$OPTARG
      ;;
    b)
      bvalFile=$OPTARG
      ;;
    m)
      mask=$OPTARG
      ;;    
    h|?)
      echo $flag
      usage
      exit 2
      ;;
  esac
done


## main 
imExt=.nii.gz
bvals=`cat $bvalFile`
dtiDir=$(dirname "${dtiVol}")
IFS=', '
read -r -a array <<< "$bvals"
i=0
j=0
for b in "${array[@]}"
do
    if [ "$b" -eq "0" ]
    then
	mergeIndex[$i]=$j
	i=$((i+1))
    fi
    j=$((j+1))
done
# split dti volume
startDir=`pwd`
tempdir=/tmp/tmp_$RANDOM
mkdir $tempdir
cp $dtiVol $tempdir/.
cd $tempdir
# split volume / remember zero-based indexing
fslsplit $dtiVol vol_
# files are now called vol_0000 vol_0001 etc
vstr=''
for indx in ${mergeIndex[@]}; do
    pstr=$(printf %04d "$indx")
    vstr=${vstr}" vol_"${pstr}
done
echo merging `imglob -oneperimage ${vstr}`
fslmerge -t mergeVol `imglob -oneperimage ${vstr}`
# make mean b0 image
fslmaths mergeVol -Tmean meanB0
bet  meanB0 b0_brain -m -R -f 0.3 # try -f 0.3
mask=`remove_ext ${mask}`
cp b0_brain_mask${imExt} ${mask}${imExt}
cd $startDir
rm -rf $tempdir


