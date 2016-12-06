function mergeFiles(group,fileDir)
% merge image to 4d stack using fslmerge
% group is a vector with the group id for each file 
% example: 
% file_0   5 
% file_1   2
% file_2   5
% 
% so file 0 and 2 should be in the same group ..

% order the group index
%
Nfiles = length(group);
ord = zeros(Nfiles,2);
ord(:,2) = 0:(Nfiles-1);  % file index
ord(:,1) = group; % group index
% sort ord by group 
ord = sortrows(ord);

Ngroups = max(group);
% loop over groups
for i=1:Ngroups,
    li = find(ord(:,1) == i);
    fileInd = ord(li,2);
    doMerge(fileInd,fileDir,i);
end
    

function doMerge(index,fileDir,groupIndex)
% merge files according to index
fileStem= 'im_';
fileExt='.nii';
% construct string of filenames
files='';
for i=1:length(index),
    fn=sprintf('%s%.4i%s',fileStem,index(i),fileExt);
    files=[files,' ',fn];
end
mergeFileName=sprintf('group_%.3i.nii',groupIndex);
initDir=pwd;
cd(fileDir);
% merge
cmd=sprintf('fslmerge -t %s %s',mergeFileName,files);
fprintf('%s\n',cmd);
[err,output] = system(cmd);
if err ~= 0,
    error('Error in fslmerge wrapper); output from command:\n %s\n',output);
end
% make mean
meanFileName=sprintf('mean_group_%.3i.nii',groupIndex);
cmd=sprintf('fslmaths %s -Tmean %s',mergeFileName,meanFileName);
fprintf('%s\n',cmd);
[err,output] = system(cmd);
if err ~= 0,
    error('Error in fslmerge wrapper); output from command:\n %s\n',output);
end

cd(initDir);


