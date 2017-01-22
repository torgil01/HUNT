#!/bin/bash
# Create log Jacobian map from native -> N32 transform 
# The logJacobian can be used for tensor-based morphometry.
# The scrip uses "CreateJacobianDeterminantImage" script.
# Usage: CreateJacobianDeterminantImage \
#    imageDimension deformationField outputImage [doLogJacobian=0] [useGeometric=0]
#
# Note that we set the last option (use geometric) to false. This last option is
# supposed to use a geometric definition of the Jacobian insted of a
# finite difference def. (Think there is a paper about this.) However, in thesting
# it produces a constant image.



imDir=/home/torgil/Projects/HUNT/WorkData/
#imDir=/home/torgil/Projects/HUNT/DTI_testing/productionTest
startDir=`pwd`
warpFieldName=brain_t1w_1Warp.nii.gz

# find all the warps in $imDir
warpFiles=(`find $imDir -name $warpFieldName`)
echo $studyDirs
for warp in ${warpFiles[@]}; do    
    currentDir=`dirname ${warp}`
    jacobian=${currentDir}/logJacN32.nii.gz
    echo $currentDir
    CreateJacobianDeterminantImage 3 $warp $jacobian 1 0
done
cd $startDir




