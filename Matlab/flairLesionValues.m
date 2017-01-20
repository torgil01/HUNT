function [xdat,ydat] = flairLesionValues
% extract pixel values from flair lesions 
% get values from t1, t2-flair, fa, and md images
% we work on data in "t1-native" space, that is all images are resampled to
% t1-image space. 
% 
% T1: brain_t1.nii.gz 
% Flair: FLAIR/ants/wflair_t1.nii.gz 
% WMH: FLAIR/ants/wwmh_t1.nii.gz
% FA: DTI/ants/wFA_t1.nii.gz

% Changelog
% FIXED: Ensure that SPM12 is used for all code!
% TODO:
% -options for image normalization
% -better scaling of axis

subjDir='/home/torgil/Projects/HUNT/DTI_testing/wml/';

% settings
opt.maskType = 'wm'; % 'wm_not_wmh'; % [wmh|gm|wm|wm_not_wmh]
opt.xlab='RAD';  % use flair here
opt.ylab='AX';
opt.xdat ='rad'; % use flair here
opt.ydat ='ax';
opt.title=sprintf('%s vs %s in %s',opt.xlab,opt.ylab,opt.maskType);
opt.doFit = false;
opt.write_wml_rescaled = false; % save WMH map rated [0-4] on severity from MD
opt.vecLength = 300; % size of data array for scatterplot
meanVal=100; % mean for normalizing gm
freqArray=zeros(opt.vecLength,opt.vecLength);
[studies,~] = dirdir(subjDir);
nStudies= numel(studies);

% get scale vector appropriate for data type
reverseOrder=false;
lx = getLinearScaling(opt.xdat,opt.vecLength,reverseOrder);
reverseOrder=true;
ly = getLinearScaling(opt.ydat,opt.vecLength,reverseOrder);

% loop over studies
for i=1:nStudies,
    thisStudy = studies{i};       
    % check if there is a WMH map, if not we skip thie current case
    if ~exist(fullfile(thisStudy,'FLAIR','wml.nii.gz'),'file'),
          continue
    end      
    % assign filepaths 
    T1Dir=getT1Dir(thisStudy);
    wmhFile=fullfile(thisStudy,'FLAIR','ants','wwml_t1.nii.gz');
    gmMaskFile=fullfile(T1Dir,'c1t1w.nii.gz');
    wmMaskFile=fullfile(T1Dir,'c2t1w.nii.gz');
     
    % Read files    
    [Vwmh,wmh]=readNiiGz(wmhFile);
    [~,gmMask]=readNiiGz(gmMaskFile);
    gmMask=binarize(gmMask,0.5);
    
    % Mask for normalizing T1 and Flair 
    % GM mask for normalizing images
    normMask = gmMask;
    
    % Set mask 
    % Different masks can be used for extracing the signal 
    % possible options are 
    % wml = exctract signal from wml mask
    % gm = extract signal from gm mask 
    % wm = extract signal from wm mask
    % wm_not_wml = extract signal from wm excluding wml regions
    switch opt.maskType,
        case 'wmh',
            mask = wmh;
        case 'gm',
            mask = gmMask;        
        case 'wm',
            [~,mask]=readNiiGz(wmMaskFile);
            mask = binarize(mask,0.5);
        case 'wm_not_wmh',
            [~,wm]=readNiiGz(wmMaskFile);
            wm = binarize(wm,0.5);
            mask = wm - wmh;
            % there might be some wml regions outside the wm mask 
            % we set these to zero
            mask(mask < 0) = 0;            
        otherwise
            error('unrecognized option for maskType. It is %s\n',opt.maskType);
    end
    
    % assign to linear vector
    X = setVec(opt.xdat,mask,normMask,meanVal,thisStudy);
    Y = setVec(opt.ydat,mask,normMask,meanVal,thisStudy);         
    Ix=getIndices(X,lx);
    Iy=getIndices(Y,ly);    
     
     % Note that in FreqArray it is YX!
     % Unable to vectorize this loop; have tried
     %  idx = sub2ind(size(freqArray),Ix,Iy);
     %  freqArray(idx) = freqArray(idx) +1;
     % but does not work.
     for j=1:length(Ix),    
         freqArray(Iy(j),Ix(j)) = freqArray(Iy(j),Ix(j))+1;
     end
     
     % Write "rescaled" wml maps, 
     if opt.write_wml_rescaled,         
         newWmh= fullfile(thisStudy,'FLAIR','ants','rescale_wmh.nii');
         newIm=flair.*wmh;
         newIm(newIm > 0 & newIm < 125) = 1;
         newIm(newIm >= 125 & newIm <150 ) = 2;
         newIm(newIm >= 150 & newIm <175 ) = 3;
         newIm(newIm >= 175) = 4;
         Vnew = rmfield(Vwmh,'pinfo');
         Vnew.fname = newWmh;
         spm_write_vol(Vnew,newIm);
         gzip(newWmh);
         delete(newWmh);
     end
end
% Plot frequency map
% 1st dim in array is y, 2nd is x!
figure, imagesc(lx,ly,freqArray)
xlabel(opt.xlab);
ylabel(opt.ylab);
title(opt.title);
colormap(hot(200));
set(gca,'YDir','normal')
colorbar

% Calculate fit
% we need to unwind the frequency matrix to a long vector of x,y pairs
% for curve fitting. 

% try % swap I and J
[J,I] = find(freqArray > 0);
% I is a index along lx  ** UPDATE I ==y
% J is a index along ly
% The numeric value will be x = lx(I(i)), however, some xy pair will have
% several datapoints
indx=1;
hSize=sum(freqArray(freqArray > 0));
xdat=zeros(1,hSize);
ydat=zeros(1,hSize);

for i =1:numel(I),
    % freqArray(Iy(j),Ix(j)) = freqArray(Iy(j),Ix(j))+1
    freq = freqArray(J(i),I(i));
    xv = lx(I(i)); % x == I
    yv = ly(J(i)); % y == J
    for j=1:freq,        
       xdat(indx) = xv;
       ydat(indx) = yv;
       indx = indx+1;
    end
end
if opt.doFit,
    % Linear regression
    lm = fitlm(xdat,ydat,'RobustOpts','on')
    hold on
    c = lm.Coefficients{:,'Estimate'};
    plot(lx,c(1) + c(2)*lx)
    hold off
end

% Plot histograms
figure, histogram(xdat,100,'LineStyle','none','EdgeColor','blue','Normalization','probability');
title([opt.xlab ' in ' opt.maskType] );
figure, histogram(ydat,100,'LineStyle','none','EdgeColor','blue','Normalization','probability');
title([opt.ylab ' in ' opt.maskType]);



function V = setVec(imgType,mask,normMask,meanVal,thisStudy)
switch lower(imgType),
    case 'md',
        imFile=fullfile(thisStudy,'DTI','ants','wMD_t1.nii.gz');
        [~,im]=readNiiGz(imFile);        
    case 'fa',        
        imFile=fullfile(thisStudy,'DTI','ants','wFA_t1.nii.gz');
        [~,im]=readNiiGz(imFile);        
    case 'mo',
        imFile=fullfile(thisStudy,'DTI','ants','wMO_t1.nii.gz');
        [~,im]=readNiiGz(imFile);        
    case 'flair',
        imFile=fullfile(thisStudy,'FLAIR','ants','wflair_t1.nii.gz');
        [~,im]=readNiiGz(imFile);
        im = normalizeImg(im,normMask,meanVal);        
    case 'rad',
        imFile1=fullfile(thisStudy,'DTI','ants','wL2_t1.nii.gz');
        imFile2=fullfile(thisStudy,'DTI','ants','wL3_t1.nii.gz');
        [~,L2]=readNiiGz(imFile1);
        [~,L3]=readNiiGz(imFile2);
        im = 0.5.*(L2 + L3);        
    case 'ax',
        imFile=fullfile(thisStudy,'DTI','ants','wL1_t1.nii.gz');
        [~,im]=readNiiGz(imFile);        
    case 'my',
    % We normalize the signal in T1 and FLAIR images so that mean GM is 100               
    %my=t1./flair;           
    case 't1',
        T1Dir = getT1Dir(thisStudy);
        T1File=fullfile(T1Dir,'brain_t1w.nii.gz');              
        [~,im]=readNiiGz(T1File);
        im = normalizeImg(im,normMask,meanVal);        
    otherwise
        error('Unrecognized xdat label; %s',imgType);
end
V=mask2vec(im,mask)';

function T1Dir=getT1Dir(thisStudy)
% find the correct T1 dir
if exist(fullfile(thisStudy,'T1_1','ants'),'dir'),
    T1Dir = fullfile(thisStudy,'T1_1');
elseif exist(fullfile(thisStudy,'T1_2','ants'),'dir')
    T1Dir = fullfile(thisStudy,'T1_2');
else
    error('Unable to locate T1 dir');
end

function indx = getIndices(X,sx)
[~,indx]=min(abs(bsxfun(@minus,X,sx')));


function vec=mask2vec(im,mask)
tmp=im.*mask;
vec=tmp(mask == 1);

function normImg = normalizeImg(img,mask,normVal)
% normalize image to so that mean in mask = meanVal
tmp=img.*mask;
tmp = tmp(tmp>0);
meanVal=mean(tmp(:));
normImg = (img./meanVal)*normVal;


function vec = getLinearScaling(datType,vecLength,reverseOrder)
% Return vector of "vecLength" elements containing equally spaced elements 
% 
switch lower(datType),
    case {'t1','flair'},
    % T1 and FLAIR images are scaled to a GM mean of 100
        maxVal=250;
        minVal=0;
    case 'md',
        maxVal=0.003;
        minVal=0;
    case 'fa',
        maxVal=1;
        minVal=0;
    case 'mo',
        maxVal=1;
        minVal=-1;   
    case 'rad',
        maxVal=0.003;
        minVal=0;
    case 'ax',
        maxVal=0.003;
        minVal=0;
    otherwise
        error('Unrecognized label %s\n',datType);
end

if ~reverseOrder,
    vec = linspace(minVal,maxVal,vecLength);
else
    vec = linspace(maxVal,minVal,vecLength);
end
