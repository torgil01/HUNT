#!/bin/bash
# resample 4D stack using "ResampleImageBySpacing"
#
# Usage:
# resampleStack.sh inStack outStack
# 
# depends on "coreutils"
#

# we need inStack and outStack to be specified as absolute paths
# which might not be the case. Use the readlink command from coreutils to
# ensure that they are specified as absolute paths
inStack=`readlink -f $1`
outStack=`readlink -f $2`
startDir=`pwd`

# set up tmpdir
tmpdir=`mktemp -d`

# split stack to tmpdir
fslsplit $inStack ${tmpdir}/im_ -t
cd $tmpdir
inputFiles=(im_*)
for f in ${inputFiles[@]}; do
    ResampleImageBySpacing 3 ${f}  R_${f} 2 2 2 0 0 1
done
# delete orig files
rm im_*.nii.gz

imgList=(R_im_*)
fslmerge -t ${outStack} `imglob -oneperimage ${imgList[@]}`

for nam in ${imgList[@]}; do
    echo $nam
done

cd $startDir
rm -r $tmpdir
