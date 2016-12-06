function compareTransforms
% compare different ants transforms 

filesA={'/home/torgil/Projects/HUNT/mkTemplate/Isotropic/Images/000138/orig/wt1w_000138.nii',...
    '/home/torgil/Projects/HUNT/mkTemplate/Isotropic/Images/005201/orig/wt1w_005201.nii',...
    '/home/torgil/Projects/HUNT/mkTemplate/Isotropic/Images/008653/orig/wt1w_008653.nii'};

filesB={'/home/torgil/Projects/HUNT/mkTemplate/Isotropic/Images/000138/iso/wt1w_000138-iso.nii',...
    '/home/torgil/Projects/HUNT/mkTemplate/Isotropic/Images/005201/iso/wt1w_005201-iso.nii',...
    '/home/torgil/Projects/HUNT/mkTemplate/Isotropic/Images/008653/iso/wt1w_008653-iso.nii'};



for i=1:numel(filesA),
    [imdir,~] = fileparts(filesA{i});
    [baseFlder,~] = fileparts(imdir);
    diffFile = fullfile(baseFlder,'sqrDiff.nii');
    imcalc({filesB{i},filesA{i}},diffFile,'sqrt((i1 - i2).^2)')
end
