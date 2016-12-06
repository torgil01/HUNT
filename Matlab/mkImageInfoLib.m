function mkImageInfoLib
% make structure for identifying the various image series
% the inf struct is saved and later used in the "hunt_deploy" script


inf(1).dat = fslinfo('/home/torgil/ImageStore/HUNT/test/nii/9410000009469/1/0001_GR_.nii.gz');
inf(1).type = 'localizer';
inf(1).rename = 'localizer';

inf(2).dat = fslinfo('/home/torgil/ImageStore/HUNT/test/nii/9410000009469/2/0002_GR_.nii.gz');
inf(2).type = 'localizer2';
inf(2).rename = 'localizer2';

inf(3).dat = fslinfo('/home/torgil/ImageStore/HUNT/test/nii/9410000009469/3/0003_GR_.nii.gz');
inf(3).type = 'T1';
inf(3).rename = 't1w';

inf(4).dat = fslinfo('/home/torgil/ImageStore/HUNT/test/nii/9410000009469/4/0004_SE_.nii.gz');
inf(4).type = 'T2';
inf(4).rename = 't2w';

inf(5).dat = fslinfo('/home/torgil/ImageStore/HUNT/test/nii/9410000009469/5/0005_SE_IR_.nii.gz');
inf(5).type = 'FLAIR';
inf(5).rename = 'flair';

inf(6).dat = fslinfo('/home/torgil/ImageStore/HUNT/test/nii/9410000009469/6/0006_GR_.nii.gz');
inf(6).type = 'SWI';
inf(6).rename = 'swi';

inf(7).dat = fslinfo('/home/torgil/ImageStore/HUNT/test/nii/9410000009469/7/0007_EP_SE_.nii.gz');
inf(7).type = 'DTI';
inf(7).rename = 'dti';

inf(8).dat = fslinfo('/home/torgil/ImageStore/HUNT/test/nii/9410000009469/8/0008_GR_.nii.gz');
inf(8).type = 'TOF';
inf(8).rename = 'tof';

inf(9).dat = fslinfo('/home/torgil/ImageStore/HUNT/test/nii/9410000009469/9/0009__.nii.gz');
inf(9).type = 'SLICEPOS';
inf(9).rename = 'slicepos';

inf(10).dat = fslinfo('/home/torgil/ImageStore/HUNT/test/nii/9410000009469/11/0011_EP_SE_.nii.gz');
inf(10).type = 'DTI_DERIVED';
inf(10).rename = 'dti-derived';

% some flair images have 24 slices 
inf(11).dat = fslinfo('/home/torgil/Projects/HUNT/SourceData/NiiRaw/hunt_2009_01/9410000000107/5/0005_SE_IR_.nii.gz');
inf(11).type = 'FLAIR';
inf(11).rename = 'flair';
% some flair images have 14 slices 
%inf(12).dat = fslinfo('/home/torgil/Projects/HUNT/SourceData/NiiRaw2_flair_fix/9410000000299/5/0005_SE_IR_.nii.gz');
%inf(12).type = 'FLAIR';
%inf(12).rename = 'flair';



% some T2 have  24
% inf(13).dat = fslinfo('/home/torgil/Projects/HUNT/SourceData/NiiRaw2_flair_fix/9410000000107/4/0004_SE_.nii.gz');
% inf(13).type = 'T2';
% inf(13).rename = 't2w';

% % some T2 have  24
% inf(14).dat = fslinfo('/home/torgil/Projects/HUNT/SourceData/NiiRaw2_flair_fix/9410000000299/4/0004_SE_.nii.gz');
% inf(14).type = 'T2';
% inf(14).rename = 't2w';
% 
% % some flair images have different fov 
% inf(15).dat = fslinfo('/home/torgil/Projects/HUNT/SourceData/NiiRaw2_flair_fix/9410000000381/5/0005_SE_IR_.nii.gz');
% inf(15).type = 'FLAIR';
% inf(15).rename = 'flair';
% 
% 
% % some flair images have different fov 
% inf(16).dat = fslinfo('/home/torgil/Projects/HUNT/SourceData/NiiRaw2_flair_fix/9410000000435/5/0005_SE_IR_.nii.gz');
% inf(16).type = 'FLAIR';
% inf(16).rename = 'flair';
% 
% % some flair images have different fov 
% inf(17).dat = fslinfo('/home/torgil/Projects/HUNT/SourceData/NiiRaw2_flair_fix/9410000000589/5/0005_SE_IR_a.nii.gz');
% inf(17).type = 'FLAIR';
% inf(17).rename = 'flair';

% some flair images have different fov 
% inf(12).dat = fslinfo('/home/torgil/Projects/HUNT/SourceData/NiiRaw_dcm2nii/9410000001029/3/18991230_000000s003a1000.nii.gz');
% inf(12).type = 'T1';
% inf(12).rename = 't1w';

% some flair images have different fov 
inf(12).dat = fslinfo('/home/torgil/Projects/HUNT/SourceData/NiiRaw_dcm2nii/missing_fikk_juni_10/9410000000480/im_5/t1w.nii.gz');
inf(12).type = 'T1';
inf(12).rename = 't1w';


% some flair images have different fov 
inf(13).dat = fslinfo('/home/torgil/Projects/HUNT/SourceData/NiiRaw_dcm2nii/missing_fikk_juni_10/9410000004860/im_11/t1w.nii.gz');
inf(13).type = 'T1';
inf(13).rename = 't1w';

% some flair images have different fov 
inf(14).dat = fslinfo('/home/torgil/Projects/HUNT/SourceData/NiiRaw_dcm2nii/missing_fikk_juni_10/9410000004914/im_1/t1w.nii.gz');
inf(14).type = 'T1';
inf(14).rename = 't1w';




save('series_info.mat','inf');



