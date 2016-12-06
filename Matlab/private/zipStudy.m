function zipStudy(studyDir)
% convert *.nii.gz files to *.nii in studyDir (and its subdirectories)
niiFiles = findFiles(studyDir,'.*\.nii$');
for i=1:numel(niiFiles),
   gzip(niiFiles{i});
   delete(niiFiles{i});
end