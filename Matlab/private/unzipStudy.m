function unzipStudy(studyDir)
% convert *.nii.gz files to *.nii in studyDir (and its subdirectories)
gzipFiles = findFiles(studyDir,'.*\.nii\.gz$');
for i=1:numel(gzipFiles),
   gunzip(gzipFiles{i});
   delete(gzipFiles{i});
end