#!/bin/bash

function usage {
  echo "stack images for HUNT data"
  echo "hack of original script with insertion of null data"
  echo "select only images from the ids in csv file"
  echo "Usage:  "
  echo "$0  -i <image directory> -c <csv-file> -o <imageStack> -f <image-name> [-R]"
}

# test for empty args
if [ $# -eq 0 ] 
    then
      usage
      exit 2
fi

# parse args
resample=false
# all args expect a parameter except R
while getopts "i:o:c:f:R" flag
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
	echo ${csvFile}
      ;;
    f)
      fileName=$OPTARG
      ;;
    R)
      resample=true
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
while IFS=, read col1 col2 col3 col4 col5
do
    ID[$i]=${col2}
    i=$((i+1))
done < ${csvFile}
# rm 1st element
ID=("${ID[@]:1}")

if [ "$resample" = false ] ; then
# put a textfile with file order at same loc as outStack
    # Null file is 1 mm iso
    nullFile=/home/torgil/Projects/HUNT/mkTemplate/FinalTemplates/null.nii.gz
    fn=`remove_ext ${outStack}` # FSL routine
    textFile=${fn}.txt
    date > $textFile
    imgList=''
    for id in ${ID[@]}; do
	subjDir=${imDir}/${id}
	if [ -d "$subjDir" ]
	   then
	   inFile=`find $subjDir -type f -name ${fileName}`	   
	   # best if we could skip this
	   if [ -f "$inFile" ]
	   then
	       imgList="${imgList} ${inFile}"
	       echo $inFile
	       echo $inFile >> $textFile
	   else
	       imgList="${imgList} ${nullFile}"
	       echo $id_NULL
	       echo $id_NULL >> $textFile
	   fi
	else
	    echo "$subjDir : missing id"
	    exit -1
        fi
    done
else
    nullFile=/home/torgil/Projects/HUNT/mkTemplate/FinalTemplates/null_2mm.nii.gz
    fn=`remove_ext ${outStack}` # FSL routine
    textFile=${fn}.txt
    date > $textFile
    imgList=''
    tmpDir=`mktemp -d` # mktemp makes dir
    for id in ${ID[@]}; do
	subjDir=${imDir}/${id}
	if [ -d "$subjDir" ]
	   then	
	       inFile=`find $subjDir -type f -name ${fileName}`

	       # best if we could skip this
	       if [ -f "$inFile" ]
	       then
		   fname=`basename $inFile`		   
		   destFile=${tmpDir}/${id}_${fname}
		   # resample file to tempdir
		   ResampleImageBySpacing 3 ${inFile}  ${destFile} 2 2 2 0 0 1
		   echo $inFile
		   echo $inFile >> $textFile
	       else
		   # insert a null file
		   destFile=${tmpDir}/${id}_NULL.nii.gz
		   cp $nullFile $destFile
	       fi
	       imgList="${imgList} ${destFile}"
	else
	    echo "$subjDir : missing id"
	    exit -1
        fi  
    done
    
fi

# do the merge
fslmerge -t ${outStack} `imglob -oneperimage ${imgList}`



if [ "$resample" = true ] ; then    
    rm -rf $tmpDir
fi




