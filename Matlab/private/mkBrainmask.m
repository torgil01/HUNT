function varargout= mkBrainmask(t1wFile)
% Usage
% mkBrainmask(t1wFile)
% MaskedT1w = mkBrainmask(t1wFile)
% [MaskedT1w, brainmask] = mkBrainmask(t1wFile)
% 
% make brainmask based on spm12 seg results
% insted of making a mask of gm+wm+csf, sligtly better results are
% obtained using max(gm,wm,csf) .* inv(max(c4,c5))
% 
%brainmaskName = 'brainmask.nii';

% ## defaults
% TODO: this should be passed through the opt var 
brainPrefix='brain_';
thr = 0.01;  % update mar 05 // use 0.01 here !!
filt = 4;
filtHeadmask = 8; % use a large filter here

[t1wDir,~,~] = fileparts(t1wFile);
% find tissue classes
wmFile = addInFront(t1wFile,'c2');
gmFile = addInFront(t1wFile,'c1');
csfFile= addInFront(t1wFile,'c3');
c4File = addInFront(t1wFile,'c4');
c5File = addInFront(t1wFile,'c5');


% do this in memory
Vt1 = spm_vol(t1wFile);
t1w = spm_read_vols(Vt1);
imDim = size(t1w);
prob = zeros([imDim,3]);
cprob = zeros([imDim,2]);

% prob array is the probability maps for wm, gm and csf
prob(:,:,:,1) = spm_read_vols(spm_vol(wmFile));
prob(:,:,:,2) = spm_read_vols(spm_vol(gmFile));
prob(:,:,:,3) = spm_read_vols(spm_vol(csfFile));
% cprob array is the probability maps for the c4 and c5 components
cprob(:,:,:,1)  = spm_read_vols(spm_vol(c4File));
cprob(:,:,:,2)  = spm_read_vols(spm_vol(c5File));


tarray1 = max(cprob,[],4); % bmax
tarray3 = max(prob,[],4); % bmax
tarray2 = tarray3 - 0.2*tarray1;

% make head mask and save as binary mask(later used in QA) 
headMask = max(tarray1,tarray3);
Vtmp = rmfield(Vt1,'pinfo');
Vtmp.fname = addInFront(t1wFile,'tmpHeadmask_');
spm_write_vol(Vtmp,headMask);
spm_smooth(Vtmp.fname,Vtmp.fname,filtHeadmask,0); 
headMask = spm_read_vols(spm_vol(Vtmp.fname));
headMask = binarize(headMask,0.05);
delete(Vtmp.fname);
Vheadmask = rmfield(Vt1,'pinfo');
Vheadmask.fname = addInFront(t1wFile,'headmask_');
spm_write_vol(Vheadmask,headMask);

% Make brainmask and mask out the brain
% need to save tmpfile for smp_smooth
Vtmp = rmfield(Vt1,'pinfo');
Vtmp.fname = addInFront(t1wFile,'tmp_');
spm_write_vol(Vtmp,tarray2);
spm_smooth(Vtmp.fname,Vtmp.fname,filt,0); 
tarray1 = spm_read_vols(spm_vol(Vtmp.fname));
tarray2 = binarize(tarray1,thr);

Vt1 = spm_vol(t1wFile);
% save brainmask
Vmask = rmfield(Vt1,'pinfo');
Vmask.fname = fullfile(t1wDir,'brainmask.nii');
spm_write_vol(Vmask,tarray2);
% mask brain and save 
tarray1 = t1w.*tarray2;
Vbrain = rmfield(Vt1,'pinfo');
Vbrain.fname = addInFront(t1wFile,brainPrefix);
spm_write_vol(Vbrain,tarray1);

% delete temp files
delete(Vtmp.fname);

switch nargout,
    case 0,

    case 1,
        varargout{1} = Vbrain.fname;
    case 2,
        varargout{1} = Vbrain.fname;
        varargout{2} = Vmask.fname;
    otherwise,
        error('only one or two output args');
end

        



