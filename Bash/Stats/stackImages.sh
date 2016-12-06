#!/bin/bash

function usage {
  echo "stack images for HUNT data"
  echo "hack of original script with insertion of null data"
  echo "select only images from the ids in csv file"
  echo "Usage:  "
  echo "$0  -i <image directory> -c <csv-file> -o <imageStack> -f <image-name>"
}

# test for empty args
if [ $# -eq 0 ] 
    then
      usage
      exit 2
fi

# parse args

while getopts "i:o:c:f:" flag
do
  case "$flag" in
    i)
      imDir=$OPTARG
      ;;
    o)
      outStack=$OPTARG
      ;;
    c)
      csvFile=$OPTARG
      ;;
    f)
      fileName=$OPTARG
      ;;    
    h|?)
      echo $flag
      usage
      exit 2
      ;;
  esac
done



# assume that the csv file have two columns, ID and type
# if type == Null the 
i=0
# must read all cols
while IFS=, read col1 col2 col3 col4 
do
    ID[$i]=${col2}
    i=$((i+1))
done < ${csvFile}

# put a textfile with file order at same loc as outStack
fn=`remove_ext ${outStack}` # FSL routine
textFile=${fn}.txt
date > $textFile
imgList=''
for id in ${ID[@]}; do
    subjDir=${imDir}/${id}
    inFile=`find $subjDir -type f -name ${fileName}`
    # best if we could skip this
    if [ -f "$inFile" ]
       then
       imgList="${imgList} ${inFile}"
       echo $inFile
       echo $inFile >> $textFile
    fi
done

fslmerge -t ${outStack} `imglob -oneperimage ${imgList}`



    




