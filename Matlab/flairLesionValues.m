function flairLesionValues
% extract pixel values from flair lesions 
% get values from t1, t2-flair, fa, and md images
% we work on data in "t1-native" space, that is all images are resampled to
% t1-image space. 
% 
% T1: brain_t1.nii.gz 
% Flair: FLAIR/ants/wflair_t1.nii.gz 
% WMH: FLAIR/ants/wwmh_t1.nii.gz
% FA: DTI/ants/wFA_t1.nii.gz

subjDir='/home/torgil/Projects/HUNT/DTI_testing/wml/';
meanVal=100; % mean for normalizing gm
freqArray=zeros(200,200);
[studies,~] = dirdir(subjDir);
nStudies= numel(studies);
% preset axis scaling
lx=linspace(0,250,200);
% Y-axis must be reversed
ly=linspace(300,0,200);
% for md
%ly=linspace(0.003,0,200);

meanVect= zeros(nStudies,1);

% loop over studies
for i=1:nStudies,
    thisStudy = studies{i};
    % find the correct T1 dir
    if exist(fullfile(thisStudy,'T1_1','ants'),'dir'),
        T1Dir = fullfile(thisStudy,'T1_1');
    elseif exist(fullfile(thisStudy,'T1_2','ants'),'dir')
        T1Dir = fullfile(thisStudy,'T1_2');
    else
        error('Unable to locate T1 dir');
    end           
    T1File=fullfile(T1Dir,'brain_t1w.nii.gz');
    % check if there is a WMH map, if not we skip thie current case
    if ~exist(fullfile(thisStudy,'FLAIR','wml.nii.gz'),'file'),
        continue
    end
    flairFile=fullfile(thisStudy,'FLAIR','ants','wflair_t1.nii.gz');
    wmhFile=fullfile(thisStudy,'FLAIR','ants','wwml_t1.nii.gz');
    faFile=fullfile(thisStudy,'DTI','ants','wFA_t1.nii.gz');
    mdFile=fullfile(thisStudy,'DTI','ants','wMD_t1.nii.gz');
    moFile=fullfile(thisStudy,'DTI','ants','wMO_t1.nii.gz');
    gmMaskFile=fullfile(T1Dir,'c1t1w.nii.gz');
    
    %[~,fa]=readNiiGz(faFile);
    %[~,md]=readNiiGz(mdFile);
    %[~,mo]=readNiiGz(moFile);
    [Vwmh,wmh]=readNiiGz(wmhFile);
    [~,flair]=readNiiGz(flairFile);
    [~,t1]=readNiiGz(T1File);
    [~,gmMask]=readNiiGz(gmMaskFile);
    
    gmMask=binarize(gmMask,0.5);
    % Normalization
    % We normalize the signal in T1 and FLAIR images so that mean GM is 100       
    t1 = normalizeImg(t1,gmMask,meanVal);
    flair = normalizeImg(flair,gmMask,meanVal);    
    %my=t1./flair;
    
    X=mask2vec(flair,wmh)';    
    Y=mask2vec(t1,wmh)';
    Ix=getIndices(X,lx);
    Iy=getIndices(Y,ly);    
%     idx = sub2ind(size(freqArray),Ix,Iy);
%     freqArray(idx) = freqArray(idx) +1;
     
     % Note that in FreqArray it is YX!
     for j=1:length(Ix),    
         freqArray(Iy(j),Ix(j)) = freqArray(Iy(j),Ix(j))+1;
     end
     
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

% 1st dim in array is y, 2nd is x!
figure, imagesc(lx,ly,freqArray)
%figure,imshow(freqArray,[]);
xlabel('FL');
ylabel('T1');
colormap(hot(200));
set(gca,'YDir','normal')
colorbar

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




