function listScans(subjDir,outFile)
% compile list of available scans for each subject 
% The data dir must be one precessed by the "hunt_deploy" script
% the function writes a text file with 0/1 for each file type 
% Optionally it can calculate the image similarity 
% which will give an estimate on how well the images are in register.
% 02.05.16 fix bug with wml files
opt.chkImageSim = true;

[subjPath, IDs] = dirdir(subjDir);
nSubj = numel(subjPath);
hasT1_1= zeros(nSubj,1);
hasT1_2= zeros(nSubj,1);
hasFlair = zeros(nSubj,1);
hasDTI = zeros(nSubj,1);
hasWML = zeros(nSubj,1);
hasBrain_1 = zeros(nSubj,1);
hasBrain_2 = zeros(nSubj,1);


if ~opt.chkImageSim,
    for i=1:numel(subjPath),
        hasT1_1(i) = chkSeries('T1_1',subjPath{i});
        hasT1_2(i) = chkSeries('T1_2',subjPath{i});
        hasFlair(i) = chkSeries('FLAIR',subjPath{i});
        hasDTI(i) = chkSeries('DTI',subjPath{i});
        hasWML(i) = chkSeries('WML',subjPath{i});
        hasBrain_1(i) = chkSeries('brain_1',subjPath{i});
        hasBrain_2(i) = chkSeries('brain_2',subjPath{i});
    end
    % make table
    T = table(IDs',hasT1_1,hasT1_2,hasFlair,hasWML,hasDTI,hasBrain_1,hasBrain_2,'VariableNames',...
        {'ID','T1_1','T1_2','FLAIR','WML','DTI','Brain1','Brain2'});
    % save table
    writetable(T,outFile);
else
    mniTemplate = fullfile(spm('dir'),'canonical/avg152T1.nii');
    coregStats = NaN(nSubj,6);
    for i=1:numel(subjPath),
        [hasT1_1(i), T1_1_Path] = chkSeries('T1_1',subjPath{i});
        [hasT1_2(i), T1_2_Path] = chkSeries('T1_2',subjPath{i});
        [hasFlair(i), flairPath]  = chkSeries('FLAIR',subjPath{i});
        [hasDTI(i), dtiPath] = chkSeries('DTI',subjPath{i});
        hasWML(i) = chkSeries('WML',subjPath{i});
        [hasBrain_1(i), brainPath_1] = chkSeries('brain_1',subjPath{i});
        [hasBrain_2(i), brainPath_2] = chkSeries('brain_2',subjPath{i});
        
        % image sim calc there must be a t1 scan pesent 
        if hasT1_1(i),
            coregStats(i,1) = myspm_imageSimilarity(mniTemplate,T1_1_Path,'ncc');
            if hasT1_2(i),
                coregStats(i,2) = myspm_imageSimilarity(T1_1_Path,T1_2_Path,'ncc');
            end
            if hasFlair(i),
                coregStats(i,3) = myspm_imageSimilarity(T1_1_Path,flairPath,'nmi');
            end
            if hasDTI(i),
                coregStats(i,4) = myspm_imageSimilarity(T1_1_Path,dtiPath,'nmi');
            end
            if hasBrain_1(i),
                coregStats(i,5) = myspm_imageSimilarity(T1_1_Path,brainPath_1,'ncc');
            end
            if hasBrain_2(i),
                coregStats(i,6) = myspm_imageSimilarity(T1_1_Path,brainPath_2,'ncc');
            end
        end     
    end
    % make table
    % note that ". -" is not allowed in variable names, but "_" is OK 
    T = table(IDs',hasT1_1,hasT1_2,hasFlair,hasWML,hasDTI,hasBrain_1,hasBrain_2,...
        coregStats(:,1),coregStats(:,2),coregStats(:,3),coregStats(:,4),coregStats(:,5),coregStats(:,6),...
        'VariableNames',{'ID','T1_','T1_2','FLAIR','WML','DTI','Brain1','Brain2',...
        'coregT1_mni','coregT1_T1repeat','coregT1_Flair','coregT1_DTI','coregT1_BrainMask1','coregT1_BrainMask2'});
    % save table
    writetable(T,outFile);    
end