function hasPreproc = chkPreporc(thisStudy)
% check if preporc is done
hasPreproc = false;
ppfile = fullfile(thisStudy,'preproc_stamp.mat');
if exist(ppfile,'file')
    load(ppfile);
    hasPreproc = preprocInfo.done;
end
