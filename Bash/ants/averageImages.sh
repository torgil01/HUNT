#!/bin/bash
# Create a mean image using ants` ImageMath
# The scrip find all files under <imDir> called <fileName>
# creates a mean image of these called <meanImage>
# Usage:
#   averageImages.sh <imDir> <fileName> <meanImage>
# TODO:
#  -use getops for parsing inputs
#  -use regexp in find command

imDir=$1
fileName=$2
meanImage=$3
# orig find cmd
files=(`find $imDir -type f -name $fileName`)
# TODO
# better to use tmp files for this
# running two instances in the same dir would fail
a=tempa.nii.gz
csum=csum.nii.gz
# number of files
nFiles=${#files[@]}
cp ${files[1]} $a
for i in $(seq 1  $((nFiles-1))); do
    echo ${files[$i]}
    ImageMath 3 $csum + $a ${files[$i]}  # csum = a + f
    mv -f $csum $a  # csum -> a
done

# compute average
#         dim out      op in1 in2
ImageMath 3 $meanImage / $a $nFiles  
rm $a 
 

