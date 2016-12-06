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