function QA= dtiQA(subjDir)
% function QA= dtiQA(subjDir)
% Calculate QA parameters for the DTI part of the HUNT study

% presets
opt.rerun = false; % if QA is done we skip it when rerun = false 

% we need to drill down each study dir
[studies, ID] = dirdir(subjDir);
nStudies= numel(studies);
% loop over studies



studyCount = 0;
for i=1:nStudies,
    thisStudy = studies{i};
    if exist(fullfile(thisStudy,'T1_1','ants'),'dir'),
        t1Dir = fullfile(thisStudy,'T1_1');
    elseif exist(fullfile(thisStudy,'T1_2','ants'),'dir'),
        t1Dir = fullfile(thisStudy,'T1_2');
    else
        warning('T1 dir not found in %s skipping\n',thisStudy)
        continue
    end
    
    [hasDti,~] = chkSeries('DTI',thisStudy);
    % check if there is a dti scan
    if ~hasDti,
            fprintf('%s No DTI, skipping\n',ID{i});
        continue
    end
    dtiDir = fullfile(thisStudy,'DTI');
   
    % we place qa-related files in "qaDir"
    qaDir = fullfile(dtiDir,'dti_QA');    
    if ~exist(qaDir,'dir'),        
        mkdir(qaDir);
    end
    if (~opt.rerun && exist(fullfile(qaDir,'QA.mat'),'file'))
        fprintf('%s :: QA already done, skipping\n',ID{i});
        continue
    end
    % ok, we are processing this one, increase study couner and go on
    studyCount = studyCount +1;
    QA(studyCount).id = ID{i};
    QA(studyCount).datestamp = datetime;    
        
    dti = fullfile(dtiDir,'dti.nii.gz');
    mask = fullfile(dtiDir,'dti_mask.nii.gz');
    fa = fullfile(dtiDir,'dt_FA.nii.gz');
    md = fullfile(dtiDir,'dt_MD.nii.gz');
    e1 = fullfile(dtiDir,'dt_L1.nii.gz');
    e2 = fullfile(dtiDir,'dt_L2.nii.gz');
    e3 = fullfile(dtiDir,'dt_L3.nii.gz');
    sse = fullfile(dtiDir,'dt_sse.nii.gz');
    dtCorr = fullfile(dtiDir,'corr_dti.nii.gz');
    
    % 1 chk brainmask
    % we use a brainmask derived from the DTI data, but is should overlap
    % well with the T1-brainmask 
    % 1.a calculate volume of brainmask (t1 and dti) 
    % 1.b calculate non-overlapping-volume
    t1BrainMask = fullfile(t1Dir,'brainmask.nii.gz');
    gunzip(t1BrainMask,qaDir);
    t1BrainMask = fullfile(qaDir,'brainmask.nii');
    gunzip(mask,qaDir);
    mask = fullfile(qaDir,'dti_mask.nii');    
    QA(studyCount).maskVol.dtiMask = calcVol(mask);
    QA(studyCount).maskVol.t1Mask = calcVol(t1BrainMask);
    ov = fullfile(qaDir,'mask_non_ovarlap.nii');
    imcalc({t1BrainMask,mask},ov,'abs(i1 - i2)');
    QA(studyCount).maskVol.mismatch = calcVol(ov);
    delete(ov);
    
    % 2 chk motion 
    ecclog=fullfile(dtiDir,'corr_dti.ecclog');
    chkFile(ecclog);
    QA(studyCount).movParam = avscale(ecclog);
    
    % 3 chk avarage signal in mask rawDWI
    % mean wm/gm/csf
    % a) resample T1 masks to DTI space, store in dti_qa
    % b)use fslmeants with mask to extract data
    % copy gm/wm -> qa dir
    gunzip(fullfile(t1Dir,'c1t1w.nii.gz'),qaDir);
    gunzip(fullfile(t1Dir,'c2t1w.nii.gz'),qaDir);
    gmNative = fullfile(qaDir,'c1t1w.nii');
    gmResamp = fullfile(qaDir,'gmProb.nii');
    gmMask = fullfile(qaDir,'gmMask.nii');
    wmNative = fullfile(qaDir,'c2t1w.nii');
    wmResamp = fullfile(qaDir,'wmProb.nii');        
    wmMask = fullfile(qaDir,'wmMask.nii');        
    imcalc({mask,gmNative},gmResamp,'i1.*i2');
    imcalc({mask,wmNative},wmResamp,'i1.*i2');    
    % resize does not work correctly, the bounding box becomes too large?
    %vx = spm_voxdim(fa);
    %bb = world_bb(fa);    
    %my_resize_img(gmNative,gmResamp,vx,bb,false);
    %my_resize_img(wmNative,wmResamp,vx,bb,false);    
    mkMask(gmResamp,gmMask,0.2);
    mkMask(wmResamp,wmMask,0.2); 
    % this is for step 4 
    sliceMask = createSliceMask(gmMask);
    % 
    gzip(gmMask);
    gzip(wmMask);
    delete(gmResamp,wmResamp);
    delete(t1BrainMask,mask);
    delete(gmNative,wmNative);
    delete(gmMask,wmMask);
    gmMask = replaceExt(gmMask,'.nii.gz');
    wmMask = replaceExt(wmMask,'.nii.gz');
    QA(studyCount).dti.gmTs = fslmeants(dti,gmMask);
    QA(studyCount).dti.wmTs = fslmeants(dti,wmMask);
    
    
    % 4 chk for slice dropouts 
    % slice-by-slice intensity profiles?
    % logic. the slice intensity for slice N slould be similar to the slice
    % intensity of the mean of the other slices.
    % to compute the slice-by slice intensity profile for each dti scan we
    % call fslmeants using a labeled mask where each slice and a mask for GM
    % that is we look for changes in the GM signal
    % first we generate a "slice mask file" where the lowest slice have
    % index 1 etc. 
    
    [err,output] = system(sprintf('fslmeants -i %s -m %s --label=%s',dti,gmMask,sliceMask));
    if err ~= 0,
        error('Error in fslmeants.m (fslmeants wrapper); output from command:\n %s\n',output);
    end
    % each row in output is for volume N 
    % each colum is for slice
    %cts = textscan(output(1:end),'%f'); % [repmat('%f',1,60) '\n']
    info = fslinfo(gmMask);
    nSlices = info.dim3;
    cts = textscan(output(1:end),[repmat('%f',1,nSlices) '\n']);
    ts = cell2mat(cts);
    QA(studyCount).dti.sliceIntensity = ts;
    
    
    % 5. compute mean ssd/FA/MD in gm/wm/brainmask
    % stats return 7 elements
    % mean nonzero_mean nonzero_std min max #voxels volume
     mask = fullfile(dtiDir,'dti_mask.nii.gz');
    files{1} = fa;
    files{2} = md;
    files{3} = sse;
    masks{1} = mask;
    masks{2} = gmMask;
    masks{3} = wmMask;
    ylabels = {'FA','FA_GM','FA_WM','MD','MD_GM','MD_WM','SSE','SSE_GM','SSE_WM'};
    xlabels = {'mean','nonzero_mean','std','min','max','voxels','volume'}; 
    imMean = zeros(numel(ylabels),1);
    imNonzeroMean = zeros(numel(ylabels),1);
    imStd = zeros(numel(ylabels),1);
    imMin = zeros(numel(ylabels),1);
    imMax = zeros(numel(ylabels),1);
    imVox = zeros(numel(ylabels),1);
    imVol = zeros(numel(ylabels),1);
    cnt = 0;
    for i=1:numel(files),
       for j=1:numel(masks),                   
           cnt = cnt +1;
           stats = fslstats(files{i},'-m -M -S -R -V ',masks{j});
           imMean(cnt) = stats(1);
           imNonzeroMean(cnt) = stats(2);
           imStd(cnt) = stats(3);
           imMin(cnt) = stats(4);
           imMax(cnt) = stats(5);
           imVox(cnt) = stats(6);
           imVol(cnt) = stats(7);
       end
    end
  
    T = table(imMean,imNonzeroMean,imStd,imMin,imMax,imVox,imVol);
    T.Properties.RowNames = ylabels';
    QA(studyCount).dti.stats=T;
        
    % 6. save qa vars for current subject 
    qa1 = QA(studyCount);
    fn = fullfile(qaDir,'QA.mat');
    save(fn,'qa1');
    
end



function t1Brainmask = findT1Brainmask(studyDir)
tmp = findFiles(studyDir,'brainmask.nii.gz');
t1Brainmask = tmp{1};
if isempty(t1Brainmask),
    error('T1 brainmask not found');
end


function filename= createSliceMask(imFile)
% 
V= spm_vol(imFile);
Vo = rmfield(V,'pinfo');
I = zeros(Vo.dim);
for i=1:Vo.dim(3),
    I(:,:,i) = i;
end
[refDir,]=fileparts(imFile);
Vo.fname=fullfile(refDir,'sliceMask.nii');
spm_write_vol(Vo,I);
gzip(Vo.fname);
delete(Vo.fname);
filename = replaceExt(Vo.fname,'.nii.gz');