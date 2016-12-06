function [V,img] = readNiiGz(file)
% wrapper for spm IO
if strcmp('.nii.gz',getExt(file)) == true,
    tempdir = tempname;
    gunzip(file,tempdir);
    [~,fName,~] =  fileparts(file);
    unzipFile = fullfile(tempdir,replaceExt(fName,'.nii'));
    V = spm_vol(unzipFile);
    img = spm_read_vols(V);
    V.fname = file;
    rmdir(tempdir,'s');
else
    error('file %s is not gzip',file);
end

