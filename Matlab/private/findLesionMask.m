function lesionMask = findLesionMask(flairFile)
% find lesion mask 
% it is called wml.nii
lesionMaskName = 'wml.nii';
[base,~,~] = fileparts(flairFile);
if exist(fullfile(base,lesionMaskName),'file'),
    lesionMask = fullfile(base,lesionMaskName);
else
    lesionMask = '';
end
