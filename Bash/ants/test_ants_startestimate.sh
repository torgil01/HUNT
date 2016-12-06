#!/bin/bash
# Test ANTS handling of initial estimate.
# it seems that default behavior is to match scans
# to center of mass. This is however not desirable when the
# images already are rigidly alinged. 
# It is not clear how to get ants to use the rotation matrices
# in the image headers when initializing the transform, but the following
# migh work:
#    (1) specify initial moving transform as identity transform
#    (2) specify initial moving transform as origin (ants fails here)
# 
# We need to test if there are any benefits syn-only + identity vs.
# rigid + syn 

# 29.11.2016 --- this does not work!
# ants is not able to read SPM-nifti correctly



export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=12

imDir=/home/torgil/Projects/HUNT/DTI_testing/initialTransform
identity=/home/torgil/Projects/HUNT/ProcessingScripts/Bash/ants/id.txt

startDir=`pwd`
faFileName=dt_FA.nii.gz
b0FileName=dt_S0.nii.gz
t1Name=brain_t1w.nii.gz
t1WMFileName=c2t1w.nii.gz
t1WMtargetName=t1WM_masked.nii.gz

# first make a list of all studies with DTI
# note the braces () which makes output a array
faFiles=(`find $imDir -type f -name $faFileName`)

for fa in ${faFiles[@]}; do
# set up a ants subdirectory under dti dir
    dirName=`dirname $fa`
    cd $dirName
    if [ ! -d "ants" ]; then
	mkdir ants
    fi
    dtiAntsDir=${dirName}/ants
    cd ants
    b0=${dirName}/${b0FileName}
    
    # find the warps under T1_1 or T1_2
    studyDirName=`dirname $dirName`
    ID=`basename ${studyDirName}`
    t1AntsDir=''
    if [ -d $studyDirName/T1_1/ants ]; then
	t1Dir=$studyDirName/T1_1
    else
	if [ -d $studyDirName/T1_2/ants ]; then
	    t1Dir=$studyDirName/T1_2	    
	else
	    exit -1
	fi
    fi
    t1AntsDir=${t1Dir}/ants
    t1File=${t1Dir}/${t1Name}
    t1Brainmask=${t1Dir}/brainmask.nii.gz    



    # syn only initial transform is identity
    target=${t1File}
    moving=${b0}
    warpName=b0_to_t1_unity
    faWarped=wfa_identity_syn.nii.gz
    antsRegistration  --verbose 1\
                      --dimensionality 3\
		      --float 0\
		      --output [${warpName},${warpName}Warped.nii.gz,${warpName}InverseWarped.nii.gz]\
		      --interpolation Linear\
		      --use-histogram-matching 0\
		      --winsorize-image-intensities [0.005,0.995]\
		      --initial-moving-transform ${identity}\
		      --transform SyN[0.1,3,0]\
		      --metric MI[${target},${moving},1,32]\
		      --convergence [50x0,1e-6,10]\
		      --shrink-factors 2x1 \
		      --smoothing-sigmas 1x0vox

    antsApplyTransforms -d 3 -i ${fa} \
   			-r ${target} \
   			-o ${faWarped} \
      			-t ${warpName}1Warp.nii.gz \
      			-t ${warpName}0GenericAffine.mat -v 1

exit 0

    # rigid+syn
    target=${t1File}
    moving=${b0}
    warpName=b0_to_t1_origin
    faWarped=wfa_rigid_syn.nii.gz

    antsRegistration --verbose 1\
		     --dimensionality 3\
		     --float 0\
		      --output [${warpName},${warpName}Warped.nii.gz,${warpName}InverseWarped.nii.gz]\
		     --interpolation Linear\
		     --use-histogram-matching 0\
		     --winsorize-image-intensities [0.005,0.995]\
		     --initial-moving-transform [${target},${moving},1]\
		     --transform Rigid[0.1]\
		     --metric MI[${target},${moving},1,32,Regular,0.25]\
		     --convergence [1000x500x250x0,1e-6,10]\
		     --shrink-factors 8x4x2x1\
		     --smoothing-sigmas 3x2x1x0vox\
		     --transform SyN[0.1,3,0]\
		     --metric MI[${target},${moving},1,32]\
		     --convergence [50x0,1e-6,10]\
		     --shrink-factors 2x1\
		     --smoothing-sigmas   

    antsApplyTransforms -d 3 -i ${fa} \
   			-r ${target} \
   			-o ${faWaped} \
      			-t ${warpName}1Warp.nii.gz \
      			-t ${warpName}0GenericAffine.mat -v 1

    
done
cd $startDir
