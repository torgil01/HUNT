function createSliceMask(imFile)
% Create a "slice mask". which is a binary mask image where slice 1
% have value 1, slice 2 have value 2 and so on.

V= spm_vol(imFile);
Vo = rmfield(V,'pinfo');
I = zeros(Vo.dim);
for i=1:Vo.dim(3),
    I(:,:,i) = i;
end
[refDir,]=fileparts(imFile);
Vo.fname=fullfile(refDir,'sliceMask.nii');
spm_write_vol(Vo,I);
gzip(Vo.fname);
delete(Vo.fname);