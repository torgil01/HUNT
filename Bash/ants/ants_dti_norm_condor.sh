#!/bin/bash
# Normalize DTI images to T1-template
# We adopt the approach of Tustison, HBM, 2014 for DTI normalization, with some
# modifications. We compute the tensor and DTI indices in native space, and 


# number of cores
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=12

imDir=/home/torgil/Projects/HUNT/DTI_testing/fullTest

startDir=`pwd`
faFileName=dt_FA.nii.gz
warpedFAName=wFA_t1.nii.gz
b0FileName=dt_S0.nii.gz
t1Name=brain_t1w.nii.gz
t1WMFileName=c2t1w.nii.gz
t1WMtargetName=t1WM_masked.nii.gz


TEMPLATE=/home/torgil/Projects/HUNT/mkTemplate/FinalTemplates/N32.nii.gz

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
    
    # Optimized call to antsRegistration for B0 -> T1 warps in the HUNT dataset
    # see Marixco document for details
    # we are essentially using the call in "antsRegistrationSyNQuck.sh"
    # which is much better and faster than "antsRegistrationSyN.sh"
    # the main difference between these two calls are that the former use the MI metric
    # and the latter the CC metric. Tustison, HBM 2014, have shown that MI is best for DTI data.
    # we add 10 iterations at the finest level (compared to 0 in the
    # "antsRegistrationSyNQuck.sh" call).

    
    warpName=B0_to_t1_s_test2
    target=$t1File
    moving=$b0
    warpedFA=${dtiAntsDir}/${warpedFAName}
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
		 --convergence [1000x500x250x10,1e-6,10]\
		 --shrink-factors 8x4x2x1\
		 --smoothing-sigmas 3x2x1x0vox\
		 --transform Affine[0.1]\
		 --metric MI[${target},${moving},1,32,Regular,0.25]\
		 --convergence [1000x500x250x10,1e-6,10]\
		 --shrink-factors 8x4x2x1\
		 --smoothing-sigmas 3x2x1x0vox\
		 --transform SyN[0.1,3,0]\
		 --metric MI[${target},${moving},1,32]\
		 --convergence [100x70x50x10,1e-6,10]\
		 --shrink-factors 8x4x2x1\
		 --smoothing-sigmas 3x2x1x0vox

 
    antsApplyTransforms -d 3 -i ${fa} \
   			-r ${t1File} \
   			-o ${warpedFA} \
      			-t ${warpName}1Warp.nii.gz \
      			-t ${warpName}0GenericAffine.mat -v 1
        
done

