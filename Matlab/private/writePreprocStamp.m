function writePreprocStamp(thisStudy)
% report that preproc was done
ppfile = fullfile(thisStudy,'preproc_stamp.mat');
if exist(ppfile,'file')
    load(ppfile);
    indx = numel(preprocInfo.log);
else
  indx=1;
end
preprocInfo.log(indx+1).date = [datestr(now,0)];
preprocInfo.done = true;
save(ppfile,'preprocInfo');



