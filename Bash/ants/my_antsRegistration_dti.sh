#!/bin/bash
# Usage:
# my_antsRegistration_dti.sh $moving $target $warpName
#
# Optimized call to antsRegistration for B0 -> T1 warps in the HUNT dataset
# see Marixco document for details
# we are essentially using the call in "antsRegistrationSyNQuck.sh"
# which is much better and faster than "antsRegistrationSyN.sh"
# the main difference between these two calls are that the former use the MI metric
# and the latter the CC metric. Tustison, HBM 2014, have shown that MI is best for DTI data.
# we add 10 iterations at the finest level (compared to 0 in the "antsRegistrationSyNQuck.sh" call).

$movig=$1
$target=$2
$warpName=$3

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


    # antsRegistration --verbose 1\
    # 		     --dimensionality 3\
    # 		     --float 0\
    # 		     --output [${warpName},${warpName}Warped.nii.gz,${warpName}InverseWarped.nii.gz]\
    # 		     --interpolation Linear \
    # 		     --use-histogram-matching 0 \
    # 		     --winsorize-image-intensities [0.005,0.995]\
    # 		     --initial-moving-transform [${t1File},${b0},1]\
    # 		     --transform Rigid[0.1]\
    # 		     --metric MI[${t1File},${b0},1,32,Regular,0.25]\
    # 		     --convergence [1000x500x250x100,1e-6,10]\  # one extra iteration loop
    # 		     --shrink-factors 8x4x2x1\
    # 		     --smoothing-sigmas 3x2x1x0vox\
    # 		     --transform Affine[0.1]\
    # 		     --metric MI[${t1File},${b0},1,32,Regular,0.25]\
    # 		     --convergence [1000x500x250x100,1e-6,10]\ # one extra iteration loop
    # 		     --shrink-factors 8x4x2x1\
    # 		     --smoothing-sigmas 3x2x1x0vox\
    # 		     --transform SyN[0.1,3,0]\
    # 		     --metric CC[${t1File},${b0},1,4]\  # CC instead of MI!
    # 		     --convergence [100x70x50x20,1e-6,10]\
    # 		     --shrink-factors 8x4x2x1\
    # 		     --smoothing-sigmas 3x2x1x0vox
