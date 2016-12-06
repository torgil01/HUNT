function calcQA(t1wFile)
% calc some QA metrics on a T1w file
% the t1 file need to be segmented using spm 
% 

opt.tissueThr = 0.1; % threshold for each tissue class
opt.printout = true;

[t1Dir,~,~] = fileparts(t1wFile);
% find tissue classes
wmFile = addInFront(t1wFile,'c2');
gmFile = addInFront(t1wFile,'c1');
csfFile= addInFront(t1wFile,'c3');
headmaskFile= addInFront(t1wFile,'headmask_');


% do this in memory
t1w = spm_read_vols(spm_vol(t1wFile));
wm =  spm_read_vols(spm_vol(wmFile));
gm =  spm_read_vols(spm_vol(gmFile));
csf = spm_read_vols(spm_vol(csfFile));
headMask =  spm_read_vols(spm_vol(headmaskFile));


% binarize
wmMask = binarize(wm,opt.tissueThr);
gmMask = binarize(gm,opt.tissueThr);
csfMask = binarize(csf,opt.tissueThr);

% invert head mask 
background = ~headMask;

% calc stats on nonzero voxels
% GM
tmp = t1w.*wmMask;
wmSeg = tmp(tmp>0);
stats.wm.mean = mean(wmSeg(:));
stats.wm.std = std(wmSeg(:));
stats.wm.size = length(wmSeg);
% WM
tmp = t1w.*gmMask;
gmSeg = tmp(tmp>0);
stats.gm.mean = mean(gmSeg(:));
stats.gm.std = std(gmSeg(:));
stats.gm.size = length(gmSeg);
% CSF
tmp = t1w.*csfMask;
csfSeg = tmp(tmp>0);
stats.csf.mean = mean(csfSeg(:));
stats.csf.std = std(csfSeg(:));
stats.csf.size = length(csfSeg);
% background
tmp = t1w.*background;
bgSeg = tmp(tmp>0);
stats.bg.mean = mean(bgSeg(:));             
stats.bg.std = std(bgSeg(:));
stats.bg.size = length(bgSeg);
% meta 
stats.source = t1wFile;
stats.date = datetime;

% save stats as matlab datafile
qaFile = fullfile(t1Dir,'qaStats.mat');
save(qaFile,'stats');

if opt.printout;
    fprintf('mean(GM) = %8.4f\t std(GM) = %8.4f\t SNR(GM) = %8.4f\n',...
        stats.gm.mean, stats.gm.std, stats.gm.mean/stats.bg.std);
    fprintf('mean(WM) = %8.4f\t std(WM) = %8.4f\t SNR(WM) = %8.4f\n',...
        stats.wm.mean, stats.wm.std, stats.wm.mean/stats.bg.std);
    fprintf('mean(CSF) = %8.4f\t std(CSF) = %8.4f\t SNR(CSF) = %8.4f\n',...
        stats.csf.mean, stats.csf.std, stats.csf.mean/stats.bg.std);    
    fprintf('mean(background) = %8.4f\t std(background) = %8.4f\t \n',...
        stats.bg.mean, stats.bg.std);    
    cnr= (stats.wm.mean - stats.gm.mean)/stats.bg.std;    
    fprintf('CNR(gm-wm) = %8.4f\n',cnr);            
end




