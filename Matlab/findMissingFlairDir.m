function findMissingFlairDir(wmlDir,deployDir)
% script for finding missing flair dirs 
% need to check these manually 
% apparently some flair images are not converte from the rawNii directory 
% 
opt.wmlFileName = 'wml.nii.gz';
wmlFiles = findFiles(wmlDir,'.*FLAIR_roi\.nii\.gz$');
wmlIDs = setIDs(wmlFiles);
[studyDirs, id] = dirdir(deployDir);

for i=1:numel(id),
    % has this id a wml?
    % fprintf('%s\n',id{i});
    tf = strncmp(id{i},wmlIDs,13);
    indx = find(tf ==1);
    if ~isempty(indx),
        destFlairDir = fullfile(studyDirs{i},'FLAIR');
        if ~exist(destFlairDir,'dir'),
            % in some cases the FLAIR image has not been deployed 
            str = sprintf('Missing FLAIR dir %s wlmref = %s', destFlairDir,wmlFiles{indx(1)});
            fprintf('%s\n',str);
        end
        
    end
end


function idList = setIDs(wmlFiles)
% extract the reduced id from the filename and
% return a list with the full id
nFiles = length(wmlFiles);
idList = cell(nFiles,1);
startNum = '94100000';
for i=1:nFiles,
    [~, filename, ~] = fileparts(wmlFiles{i});
    reducedId = filename(1:5);
    idList{i} = [startNum reducedId];
    if numel(idList{i}) ~= 13,
        warning('id length incorrect for %s\n',wmlFiles{i})
    end
end


