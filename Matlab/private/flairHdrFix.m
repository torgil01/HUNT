function flairHdrFix(file,ref)
% fix the wml header problem 
% > the nii headers for the wml files and the associated FLAIR file in the WML
% directory is inconsistent with the FLAIR images converted from the
% original DICOM data. Also thedata storage is different.
% This is probably due to different conversion software beeing used for
% converting from DICOM to nifti. This function fixes the problem by 
% (1) flipping the data array in the RL driection
% (2) replacing the header with the FLAIR header from our DICOM conversion
% This ensures that the FLAIR/WML images are aligned to the other images 
% 
% 08.02.2016 Verified for 0374

% replace image hader
zipFile = false;
zipRef = false;
extFile = getExt(file);
extRef = getExt(ref);

if strcmp(extFile,'.nii.gz'),
    zipFile = true;
    gunzip(file);
    delete(file);
    fixFile = replaceExt(file,'.nii');
else
    fixFile = file;
end

if strcmp(extRef,'.nii.gz'),
    zipRef = true;
    gunzip(ref);
    delete(ref);
    refFile = replaceExt(ref,'.nii');
else
    refFile = ref;
end

VRef = spm_vol(refFile);
VFix = spm_vol(fixFile);

fixDat = int16(spm_read_vols(VFix));
fixDat = flip(fixDat,2);
% sometimes wml have extra slices
if VFix.dim(3) ~= VRef.dim(3),
    Vfixed.dim = VFix.dim;
    Vfixed.dt = VRef.dt;
    Vfixed.pinfo = VRef.pinfo;
    Vfixed.mat = VRef.mat;
    Vfixed.n = VRef.n;
    Vfixed.descrip = VRef.descrip;
    Vfixed.private = VRef.private;
else    
    Vfixed = VRef;
end

% new filename 
[baseDir,~] = fileparts(fixFile);
Vfixed.fname = fullfile(baseDir,'flair-fixed.nii');
spm_write_vol(Vfixed,fixDat);
delete(fixFile);
movefile(Vfixed.fname,fixFile);

if zipRef,
    gzip(refFile);
    delete(refFile);
end
if zipFile,
    gzip(fixFile);
    delete(fixFile);
end

