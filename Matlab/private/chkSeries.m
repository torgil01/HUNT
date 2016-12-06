function varargout = chkSeries(type,subjDir)
% hasScan = chkSeries(type,subjDir)
% [hasScan, filePath] = chkSeries(type,subjDir)
% check type
% seriesNames={'T1','T2','FLAIR','DTI','DTI_DERIVED','TOF','localizer','localizer2','SWI','SLICEPOS','Unknown'};
%
% TODO: 
%  does not handle nii files well, only nii.gz


hasScan = 0;
pathToFile = '';
seriesPath = fullfile(subjDir,type);
switch type,
    case {'T1_1','T1_2'},
        if exist(seriesPath,'dir') && (exist(fullfile(seriesPath,'t1w.nii.gz'),'file') || exist(fullfile(seriesPath,'t1w.nii'),'file')),
            hasScan=1;
            if exist(fullfile(seriesPath,'t1w.nii.gz'),'file'),
                pathToFile = fullfile(seriesPath,'t1w.nii.gz');
            else
                pathToFile = fullfile(seriesPath,'t1w.nii');
            end
        end
    case 'FLAIR',
         if exist(seriesPath,'dir') && exist(fullfile(seriesPath,'flair.nii.gz'),'file'),
            hasScan=1;
            pathToFile = fullfile(seriesPath,'flair.nii.gz');
         end        
    case 'WML',   
        seriesPath = fullfile(subjDir,'FLAIR');
         if exist(seriesPath,'dir') && exist(fullfile(seriesPath,'wml.nii.gz'),'file'),
            hasScan=1;
            pathToFile = fullfile(seriesPath,'wml.nii.gz');
         end
    case 'DTI',
         if exist(seriesPath,'dir') && exist(fullfile(seriesPath,'dti.nii.gz'),'file'),
            hasScan=1;
            pathToFile = fullfile(seriesPath,'dti.nii.gz');
         end
    case 'brain_1',   
        seriesPath = fullfile(subjDir,'T1_1');
         if exist(seriesPath,'dir') && exist(fullfile(seriesPath,'brain_t1w.nii.gz'),'file'),
            hasScan=1;
            pathToFile = fullfile(seriesPath,'brain_t1w.nii.gz');
         end
    case 'brain_2',   
        seriesPath = fullfile(subjDir,'T1_2');
         if exist(seriesPath,'dir') && exist(fullfile(seriesPath,'brain_t1w.nii.gz'),'file'),
            hasScan=1;
            pathToFile = fullfile(seriesPath,'brain_t1w.nii.gz');
         end
    otherwise
        error('unknown type');
end

switch nargout,
    case 1,
        varargout{1} = hasScan;
    case 2,
        varargout{1} = hasScan;
        varargout{2} = pathToFile;
    otherwise,
        error('Incorrect number of input args.')        
end
