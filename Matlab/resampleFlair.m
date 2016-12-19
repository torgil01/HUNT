function resampleFlair
% Function for resampling the flair/wml images to the same resolution as the 
% T1 images. This makes it easier for voxel-to-voxel comarisions of 
% image values in WML regions. 

subjDir='/home/torgil/Projects/HUNT/DTI_testing/wml/';

[studies, ID] = dirdir(subjDir);
nStudies= numel(studies);
% loop over studies
for i=1:nStudies,
    thisStudy = studies{i};
    % find the correct T1 dor
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
    flairFile=fullfile(thisStudy,'FLAIR','flair.nii.gz');
    wmhFile=fullfile(thisStudy,'FLAIR','wml.nii.gz');
    % gunzip unzips the file, but leaves the original intact 
    gunzip(flairFile);
    gunzip(wmhFile);
    
    flairFile=fullfile(thisStudy,'FLAIR','flair.nii');
    wmhFile=fullfile(thisStudy,'FLAIR','wml.nii');   
    
    % fix the ANTS header problem, so that ANTS play well with these files.
    replaceHdr(flairFile,wmhFile)
    
    % store the resampled files in the FLAIR folder
    rFlairFile=fullfile(thisStudy,'FLAIR','rflair.nii');
    rWmhFile=fullfile(thisStudy,'FLAIR','rwml.nii');
    gunzip(T1File);
    T1File=fullfile(T1Dir,'brain_t1w.nii');
    [bb, vox] = world_bb(T1File);        
    my_resize_img(flairFile,rFlairFile,abs(vox),bb,false);
    my_resize_img(wmhFile,rWmhFile,abs(vox),bb,false);
    
    % cleanup
    delete(flairFile);
    delete(wmhFile);    
    delete(T1File);
end