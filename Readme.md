# Preprocessing of HUNT data
Overview of the steps in the preprocessing of the HUNT dataset.

## Scripts
All preprocessing scripts are in the Bash or Matlab folders.

## Data organzation

	SourceData (moved to anoter disk)
			|
			|-----------FS5.3
			|-----------OrginalData
			|-----------TBM_3channel
			|-----------WML
			|-----------NiiRaw
	WorkData
			|
			|----------<all IDs>
	mkTemplate
            | 
            |-----------buildTemplate
			|-----------FinalTemplates
			|-----------Isotropic
			|-----------MNI
			|-----------StudyDir
			|-----------Test_translations



## Preprocessing steps

### 1. DICOM conversion
The raw DICOM data is first converted to *nii.gz* using `convert_from_dicom.sh` with the "HUNT" flag. This script uses the `dcm2nii`program for converting the DICOM files. Originally the newer `dcm2niiX` program was used, but it failed to convert the FLAIR images properly. The converted Nifty files are placed in the `niiRaw`folder. 

### 2. Data Deployment
From the "raw nifti" folder the data is deployed to the `WorkData` folder using the `huntDeploy.m` script.  The main puprose of the `huntDeploy.m` script is to identify the various DICOM series in the raw Nifty folder and rename these in a consistent manner. One can also choose which series to deploy.  For example only T1 and DTI or T1, FLAIR and DTI which is used currently. 

Afther deployment, the WML segmentations must be merged with the other data. The WML maps are in the "WML" data folder in Nifty format, and the `deployWML.m` script merges the WML maps to each subject. The WML map is placed under the FLAIR folder. Due to inconsistencies in the nifty rotation matrices between the FLAIR images converted in step 1 and the  WML maps, the `deployWML.m` script also copies the header from the original FLAIR file to the WML maps  and flips the data matrix in the RL-direction in order to ensure that the WML maps are in the same coordinate system as the FLAIR images. 

### 3. Concistency check
The `listScans.m` script can be used to summarize which scans are available for each subject.

### 4. Preprocessing 
The matlab scrip `hunt_preproc.m` performs preprocessing primarely to ensure that all images are in register. *Note that images are always aligned to the 1st T1 series.* The preprocessing script perform the following steps.

1. coregister all images to T1
2. coregister T1 to mni + all other
3. segment T1
4. calc SNR on T1
5. make T1-brainmask
6. make T1brain
7. bias field correction (N4 -ants)

The SNR data on the T1 images are used to select the "best" T1 scan which is used to calculate the warp to the template. (See the ANTS section below.)


### 5. DTI
DTI processing is done with the `fslDTI.sh` script (`Bash/DTI/fslDti.sh`). The script performs standard DTI processing using the FSL tools;

1. Correction of eddy currents using `eddy_correct`
2. Rotation of bvecs
3. Create a brainmask
4. fit diffusion tensor usig `dtifit`


# ANTS

## Template Creation
Template created from 32 subjects using the `antsMultivariateTemplateConstruction2.sh` script. There is the study specific template `N32.nii.gz` and a warp to the MNI template.
See `buildTemplate`folder for details.

## ANTS warp of T1 images
The T1 images in native space are warped to the N32 template using `ants_submit.sh` script. 

## ANTS warp of WML
The WML maps are warped to the ANTS template space using the t1 -> template warps. Nearest neigbour interpolation is used. See `../Bash/ants/apply_flair_warps.sh`.

# Statistics
FSL's `randomise` is used for all statistics. All statistics are done in the `Stats` folder. For `randomise`all images need to be merged in a 4D volume. A script is used to copy images from `WorkData` to the appropriate `Stats`subfolder.


## TBM on Jacobian Determinants
* Smoothing
* merging


## Frequency stats on WML maps (lesion mapping)
We have only lesion maps for those with Fazekas > 1 (**check**). One must therefore fill the missing data with a empty scan. There is a empty scan (all zeros) in the image space of the ANTS template at
`HUNT/mkTemplate/FinalTemplates/null.nii.gz`. The template was made by multiplying the N32 template with zero.


```
ImageMath 3 null.nii.gz m N32.nii.gz  0
``` 

We use a R script to produce design files (for randomise) and a .csv file for selecing the scans.


## WML - FLAIR correlations
Tools for looking at the association between the intensity in FLAIR WMH lesions and other image sequences (T1 and DTI indices). FLAIR/WML images are resampled to native T1 space using `resampleFlairToT1.sh` and the voxelwise correlations are done with `flairLesionValues.m`. 

Need to do the follwing:
1. Look at FLAIR-T1 and FLAIR-MD correlations in WM (excl WML) and WML. Do only the WML regions exhibit the associations?
2. Robust procedure for normalization
3. Compute MD histograms for WM in WML
4. 


