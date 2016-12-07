#!/bin/bash
# Normalize DTI images to T1-template
# We adopt the approach of Tustison, HBM, 2014 for DTI normalization, with some
# modifications. We compute the tensor and DTI indices in native space, and 

# instead of using CONDOR we use multiple cores
# Note 12 cores give a 5x speedup!
# number of cores 
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=20

imDir=/home/torgil/Projects/HUNT/WorkData

startDir=`pwd`
faFileName=dt_FA.nii.gz
warpedFAName=wFA_t1.nii.gz
warpName=B0_to_t1_s_
b0FileName=dt_S0.nii.gz
t1Name=brain_t1w.nii.gz
t1WMtargetName=t1WM_masked.nii.gz
dtiIndices=(dt_FA.nii.gz  dt_MD.nii.gz dt_MO.nii.gz dt_L1.nii.gz dt_L2.nii.gz dt_L3.nii.gz)
# files warped to native T1
warpedDtiT1=(wFA_t1.nii.gz wMD_t1.nii.gz wMO_t1.nii.gz\
			    wL1_t1.nii.gz wL2_t1.nii.gz wL3_t1.nii.gz)
# files warped to N32 template
warpedDtiN32=(wFA_N32.nii.gz wMD_N32.nii.gz wMO_N32.nii.gz\
			      wL1_N32.nii.gz wL2_N32.nii.gz wL3_N32.nii.gz)
TEMPLATE=/home/torgil/Projects/HUNT/mkTemplate/FinalTemplates/N32.nii.gz

# first make a list of all studies with DTI
# note the braces () which makes output a array
faFiles=(`find $imDir -type f -name $faFileName`)

for fa in ${faFiles[@]}; do
    # set up a ants subdirectory under dti dir
    dtiDir=`dirname $fa`
    cd $dtiDir
    if [ ! -d "ants" ]; then
	mkdir ants	
    else
	# we assume that this is a rerun
	echo "Skipping $fa"
	continue 
    fi
    dtiAntsDir=${dtiDir}/ants
    logfile=${dtiAntsDir}/antsRegistration-log.txt
    cd ants
    b0=${dtiDir}/${b0FileName}
    
    # find the warps under T1_1 or T1_2
    studyDirName=`dirname $dtiDir`
    ID=`basename ${studyDirName}`
    t1AntsDir=''
    if [ -d $studyDirName/T1_1/ants ]; then
	t1Dir=$studyDirName/T1_1
    elif [ -d $studyDirName/T1_2/ants ]; then
	    t1Dir=$studyDirName/T1_2	    
    else
       continue
    fi
    t1AntsDir=${t1Dir}/ants
    t1File=${t1Dir}/${t1Name}
    t1TotemplateWarp=${t1AntsDir}/brain_t1w_1Warp.nii.gz
    t1TotemplateAffine=${t1AntsDir}/brain_t1w_0GenericAffine.mat
    
    
    # Optimized call to antsRegistration for B0 -> T1 warps in the HUNT dataset
    # see Marixco document for details
    # we are essentially using the call in "antsRegistrationSyNQuck.sh"
    # which is much better and faster than "antsRegistrationSyN.sh"
    # the main difference between these two calls are that the former use the MI metric
    # and the latter the CC metric. Tustison, HBM 2014, have shown that MI is best for DTI data.
    # we add 10 iterations at the finest level (compared to 0 in the
    # "antsRegistrationSyNQuck.sh" call).
    
    target=$t1File
    moving=$b0

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
    		 --smoothing-sigmas 3x2x1x0vox  > $logfile
    
    i=0
    for dtFile in ${dtiIndices[@]}; do	
	inFile=${dtiDir}/${dtFile}
	outFile=${dtiAntsDir}/${warpedDtiT1[i]}
	# warp DTI indices to T1
	antsApplyTransforms -d 3 -i ${inFile} \
     			    -r ${t1File} \
     			    -o ${outFile} \
       			    -t ${warpName}1Warp.nii.gz \
       			    -t ${warpName}0GenericAffine.mat -v 1

	# warp DTI indices to template
	outFile=${dtiAntsDir}/${warpedDtiN32[i]}
	antsApplyTransforms -d 3 -i ${inFile} \
   			    -r ${TEMPLATE} \
   			    -o ${outFile} \
			    -t ${t1TotemplateWarp} \
			    -t ${t1TotemplateAffine} \
			    -t ${warpName}1Warp.nii.gz \
      			    -t ${warpName}0GenericAffine.mat \
			    -v 1
	i=$((i+1))
    done

    # Remove warps since they take so much space
    rm ${warpName}1Warp.nii.gz 
    rm ${warpName}0GenericAffine.mat 
    rm ${warpName}1InverseWarp.nii.gz
    rm ${warpName}InverseWarped.nii.gz
    rm ${warpName}Warped.nii.gz    
done

