function hunt_preproc(subjDir,logfileName,checkRegFile)
% preproc hunt mri data using spm12

% 1. coregister all images to T1
% 2. coregister T1 to mni + all other 
% 3. segment T1
% 4. calc SNR on T1
% 5. make T1-brainmask
% 6. make T1brain
% 7. bias field correction (N4 -ants)

opt.flairFile='flair.nii';
%opt.logfileName = 'log-preproc.txt';
opt.logfileName = logfileName;
opt.coregLogfileName = 'log-coreg.txt';
opt.t1File='t1.nii';
opt.flairDir = 'Flair';
opt.t1Dir = 'T1';
opt.brainMask = 'brainmask.nii';
opt.mniTemplate = fullfile(spm('dir'),'canonical/avg152T1.nii');
opt.seriesList={'DTI','FLAIR','T1_1','T1_2'};
opt.dbug = true;
opt.skipFinished=false; % skip jobs that are done 
opt.cleanup = 'seg8'; % all or seg8
opt.chkregFile = checkRegFile; % 'checkReg.ps';
% we need to drill down each study dir
[studies, ID] = dirdir(subjDir);
nStudies= numel(studies);
% init main logfile
logfile('init',opt.logfileName);
% loop over studies
for i=1:nStudies,
    thisStudy = studies{i};
    hasPreproc = chkPreporc(thisStudy);
    if (opt.skipFinished && hasPreproc),
        logfile('write',sprintf('%s Preporc already done, skipping\n\n',ID{i}));
        fprintf('%s Preprorc already done, skipping\n',ID{i});
        continue
    end    
    [seriesPath, ~] = dirdir(thisStudy);
    nSeries = numel(seriesPath);
    if nSeries > 0,
        [hasT1_1,T1_1File] = chkSeries('T1_1',thisStudy);
        [hasT1_2, T1_2File] = chkSeries('T1_2',thisStudy);
        [~, flairFile] = chkSeries('FLAIR',thisStudy);
        [~, dtiFile] = chkSeries('DTI',thisStudy);
                        
        % if there is no T1 we skip this subject
        if (hasT1_1 == 1 || hasT1_2 == 1),                           
            % do the preprocessing for current study
            tic;
            pinfo= doPreproc(thisStudy,T1_1File,T1_2File,flairFile,dtiFile,opt);
            procTime = toc;            
            logEntry = sprintf('%s ok cpuTime\t%f\tt1->mni\t%8.4f\tt1->t1\t%8.4f\tt1-flair\t%8.4f\tt1->dti\t%8.4f\tt1->brain\t%8.4f\tt1other->brain\t%8.4f\n',...
                ID{i},procTime,pinfo.coregT1_mni,pinfo.coregT1_T1Other,pinfo.coregT1_flair,pinfo.coregT1_dti,...
                pinfo.refT1_brain,pinfo.otherT1_brain);               
            logfile('write',logEntry);            
            writePreprocStamp(thisStudy)
        else
            logfile('write',sprintf('%s empty\n',ID{i}));
        end
    else
        logfile('write',sprintf('%s empty\n',ID{i}));
    end
end

logfile('close')


function preprocSteps = doPreproc(studyDir,T1_1File,T1_2File,flairFile,dtiFile,opt)
% do the actial preporcessing    
% 1. coregister T1 to mni + all other
% 2. coregister all images to T1
% 3. segment T1
% 4. calc SNR on T1
% 5. make T1-brainmask
% 6. make T1brain
% 7. bias field correction (N4 -ants)

preprocSteps.coregT1_mni =-1;
preprocSteps.coregT1_T1Other =-1;
preprocSteps.coregT1_dti =-1;
preprocSteps.coregT1_flair =-1;
preprocSteps.refT1_brain =-1;
preprocSteps.otherT1_brain =-1;


% files are in gz 
unzipStudy(studyDir);
% remove gz ext to files 
T1_1File = replaceExt(T1_1File,'.nii');
T1_2File = replaceExt(T1_2File,'.nii');
flairFile = replaceExt(flairFile,'.nii');
dtiFile = replaceExt(dtiFile,'.nii');

id = getID(studyDir,1);

% 0. determine which T1 is the reference, if there are two, choose the last
if ~isempty(T1_2File),
    T1ref = T1_1File;
    T1other = T1_2File;
else
    T1ref = T1_1File;
    T1other = '';
end

% 1. coregister T1 to mni + all other
% fill copt
indx=1;
copt='';
if ~isempty(T1other),
    copt.otherStack{indx} = T1other;
    indx = indx +1;
end
if ~isempty(flairFile),
    copt.otherStack{indx} = flairFile;
    indx = indx +1;
    lesionMask = findLesionMask(flairFile);
    if ~isempty(lesionMask),
        copt.otherStack{indx} = lesionMask;
        indx = indx +1;
    end
end
if ~isempty(dtiFile),
    V = spm_vol(dtiFile);
    for i=indx:indx+numel(V),
        copt.otherStack{i}=sprintf('%s,%i',dtiFile,i);        
    end       
end
if isempty(copt),
    myspm_coreg(T1ref,opt.mniTemplate);
else
    myspm_coreg(T1ref,opt.mniTemplate,copt);
end
copt = '';
preprocSteps.coregT1_mni = myspm_imageSimilarity(T1ref,opt.mniTemplate,'ncc');


% 2. coregister all images to T1
% 2a. T1 other
if ~isempty(T1other),    
    myspm_coreg(T1other,T1ref);
    preprocSteps.coregT1_T1Other = myspm_imageSimilarity(T1ref,T1other,'ncc');
end
% 2b. flair (and lesion mask if it is it is there)
if ~isempty(flairFile),
    lesionMask = findLesionMask(flairFile);
    if isempty(lesionMask),
        myspm_coreg(flairFile,T1ref);        
    else
        copt.other{1} = lesionMask;
        myspm_coreg(flairFile,T1ref,copt);        
    end
    preprocSteps.coregT1_flair = myspm_imageSimilarity(T1ref,flairFile,'mi'); 
end
copt = '';
% 2c. dti file
if ~isempty(dtiFile),
    % fill in opt struct
    V = spm_vol(dtiFile);
    for i=1:numel(V)-1,
        copt.otherStack{i}=sprintf('%s,%i',dtiFile,i+1);        
    end    
    myspm_coreg(dtiFile,T1ref,copt);
    preprocSteps.coregT1_dti = myspm_imageSimilarity(T1ref,dtiFile,'mi');
end
copt = '';
% 3. segment T1 files
myspm_segment(T1ref);
if ~isempty(T1other),
    myspm_segment(T1other);
end


% 5. make T1-brainmask and mask T1
[t1RefBrain, t1RefMask] = mkBrainmask(T1ref);
preprocSteps.refT1_brain =myspm_imageSimilarity(T1ref,t1RefBrain,'ncc');
if ~isempty(T1other),
    [t1OtherBrain, t1OtherMask]  = mkBrainmask(T1other);
    preprocSteps.otherT1_brain =myspm_imageSimilarity(T1other,t1OtherBrain,'ncc');
end

% 4a. calc SNR on T1
calcQA(T1ref);
if ~isempty(T1other),
    calcQA(T1other);
end

% 5.5 print coreg graphics 
chkFiles{1} = t1RefBrain;
indx=2;
if  ~isempty(T1other),   % exist(t1OtherBrain,'file'),
    chkFiles{indx} = t1OtherBrain;
    indx = indx+1;
end
if exist(flairFile,'file'),
    chkFiles{indx} = flairFile;
    indx = indx+1;    
end
if exist(dtiFile,'file'),
    chkFiles{indx} = sprintf('%s,1',dtiFile);    
end
spm_check_registration(char(chkFiles));
for i=1:numel(chkFiles),
    % dbug
    %fprintf('%s\n',chkFiles{i});
    [baseDir, fname] = fileparts(chkFiles{i});
    [~, seriesDirName] = fileparts(baseDir);
    captionStr = [id '/' seriesDirName '/' fname]; 
    spm_orthviews('Caption', i,captionStr,'FontSize',8,'Color','Blue');
end
% add figure title
text(10,350,sprintf('%s\n',id),'Color','Red','FontSize',24);
spm_print(opt.chkregFile,'Graphics');
spm_figure('Close');

% 6 clean up files
doCleanup(studyDir,opt)

% 7 n4 correct
% note: we just owerwrite the brain image with the N4 corrected to avoid 
% generating som many files
N4BiasFieldCorrection(t1RefBrain,t1RefBrain,t1RefMask); 
if ~isempty(T1other),
    N4BiasFieldCorrection(t1OtherBrain,t1OtherBrain,t1OtherMask)
end

zipStudy(studyDir);
        
            
            
 