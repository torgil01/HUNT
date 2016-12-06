function calcCoregStats(T1ref,T1other,dtiFile,flairFile)
% calc some stats on the quality of coreg

mni = fullfile(spm('dir'),'canonical/avg152T1.nii');

coreg.id = getID(T1ref,2);
coreg.T1ref.file = T1ref;
coreg.T1ref.ncc_mni = myspm_imageSimilarity(T1ref,mni,'ncc');
if ~isempty(T1other),
    coreg.T1ref.ncc_T1other = myspm_imageSimilarity(T1ref,T1other,'ncc');    
    coreg.T1other.file = T1other;
else
    coreg.T1ref.ncc_T1other = '';
    coreg.T1other.file = '';
end
if ~isempty(dtiFile),
    coreg.T1ref.mi_dti = myspm_imageSimilarity(T1ref,dtiFile,'mi');    
    coreg.dtiFile.file = dtiFile;
else
    coreg.T1ref.mi_dti = '';
    coreg.dtiFile.file = '';
end
if ~isempty(flairFile),
    coreg.T1ref.mi_flair = myspm_imageSimilarity(T1ref,flairFile,'mi');    
    coreg.flairFile.file = flairFile;
else
    coreg.T1ref.mi_flair = '';
    coreg.flairFile.file = '';
end


[t1RefDir, ~] = fileparts(t1Ref);
coregDatFile = fullfile(t1RefDir,'coreg_dat.mat');
save(coregDatFile,coreg);



