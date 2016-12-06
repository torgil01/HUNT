function deployWML(wmlDir,deployDir)
% script for moving the wml to the deployment directory 
% the wml files are in nii format. 
% some are saved in separate folders either with the full id or "reduced"
% id, other are saved together 
% however all appears to be saved as "<reduced id>FLAIR_roi.nii.gz"
% a regexp search of the wml base folder should therefore give a list of all
% wml seg files.
% 
% another problem is that the nii headers for the wml mask is different
% from the headers in the flair images converted with dcm2niix 
% fslswapdim  + fslreorient *nearly* fixes the problem, but there is a
% small shift. To solve this issue the headers for the wml and flair images 
% in the WML dir is replaced with the flair headers in the FLAIR dir. 
% in this way the image set is in best alignment. The original FLAIR/flair 
% image is deleted. 



opt.wmlFileName = 'wml.nii.gz';
wmlFiles = findFiles(wmlDir,'.*FLAIR_roi\.nii\.gz$');
wmlIDs = setIDs(wmlFiles);
[studyDirs, id] = dirdir(deployDir);

[scriptDir,~] = fileparts(which(mfilename));
logfileName = fullfile(scriptDir,'wml-deploy-log2.txt');
logfile('init',logfileName);
logfile('write',[datestr(now,0) '\n']);

for i=1:numel(id),
    % has this id a wml?
   % fprintf('%s\n',id{i});
    tf = strncmp(id{i},wmlIDs,13);
    indx = find(tf ==1);
    if numel(indx) > 1,
        for k=1:numel(indx),
            fprintf('%s\n',wmlFiles{indx(k)});
        end
        str = sprintf('duplicate wml for %s\n',studyDirs{i});
        warning(str);
        logfile('write',str);
    end
    if ~isempty(indx),
        destFlairDir = fullfile(studyDirs{i},'FLAIR');
        if ~exist(destFlairDir,'dir'),
            % in some cases the FLAIR image has not been deployed 
            % we make a new destination flair directory 
            % skip this 
                      
        else
            % find ref Flair (the flair file we have made)
            flairRef = fullfile(destFlairDir,'flair.nii.gz');            
            % copy wml -> dest
            destFile = fullfile(destFlairDir,opt.wmlFileName);                                    
            if ~exist(destFile,'file'),
                copyfile(wmlFiles{indx(1)},destFile);
                str = sprintf('cp %s -> %s\n',wmlFiles{indx(1)},destFile);
                logfile('write',str);
                fprintf('%s',str);
                % fix wml hdr 
                flairHdrFix(destFile,flairRef);      
            else
                str = sprintf('id = %s wlm exist skipping\n',id{i});
                logfile('write',str);
                fprintf('%s',str);
            end
            % copy flair -> dest 
            % this is not neccesary
%             sourceFlair = rmExt(wmlFiles{indx(1)});
%             sourceFlair = [sourceFlair(1:end-4) '.nii.gz'];
%             destFile = fullfile(destFlairDir,'flair_tmp.nii.gz');
%             copyfile(sourceFlair,destFile);
%             str = sprintf('cp %s -> %s\n',sourceFlair,destFile);
%             logfile('write',str);
%             fprintf('%s',str);            
%             % fix flair hdr             
%             flairHdrFix(destFile,flairRef);
%             delete(flairRef);           
%             movefile(destFile,flairRef);
        end             
    end
end
logfile('close')






