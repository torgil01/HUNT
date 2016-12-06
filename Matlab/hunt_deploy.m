function hunt_deploy(sourceDir,destDir)
% deploy nii data from HUNT nii source directory
% 
% 
%sourceDir='/home/torgil/ImageStore/HUNT/test/nii/';
def.deploySeries = {'T1','FLAIR','DTI'};
def.seriesNames={'T1','T2','FLAIR','DTI','DTI_DERIVED','TOF','localizer','localizer2','SWI','SLICEPOS','Unknown'};
%def.subjectDeployList= '/home/torgil/Projects/HUNT/ProcessingScripts/Matlab/id-file-hunt.txt'; % 'all'; % specify filename if only some are to be deployed
def.subjectDeployList= 'all';
def.rename=true;
def.fileExt = '.nii.gz';
def.imFileRegexp='.*\.nii.gz$';
def.sourceDir = sourceDir;
% preload reference data for identifying files
libDat = load('series_info.mat');
def.libInfo = libDat.inf; % this is the reference data made with 'mkImageInfoLib.m'
subjList = getSubjList(def.subjectDeployList,def);
subjList
deployData(destDir,subjList,def);

% ------------------------------
% end main

function deployData(destDir,subjList,def)
    [subjFullPath, id] = dirdir(def.sourceDir);   
    for i=1:length(id),
        if any(strcmp(id{i},subjList)),
            % make subject directory in deploy dest
            myMkDir(destDir,id{i});
            seriesDirs = dirdir(subjFullPath{i});
            seriesCounter=zeros(length(def.deploySeries),1);
            destSubjDir = fullfile(destDir,id{i});
            for j=1:length(seriesDirs),
                seriesName = idSeries(seriesDirs{j},def);
                if strcmp(seriesName,'Empty'),
                    continue
                %fprintf('%s \t %s\n',seriesDirs{j},seriesName);
                elseif any(strcmp(seriesName,def.deploySeries)),
                    % one of the series we want to deploy
                    indx =find(strcmp(seriesName,def.deploySeries));
                    % need to count the number of each series type
                    seriesCounter(indx)=seriesCounter(indx)+1;
                    if strcmp(seriesName,'T1'),
                        destSeriesDirName = [seriesName '_' sprintf('%d',seriesCounter(indx))];
                    else
                        if seriesCounter(indx) > 1,
                            warning('multiple series for %s\n',seriesName);
                            destSeriesDirName = [seriesName '-' sprintf('%d',seriesCounter(indx))];
                        else
                            destSeriesDirName = seriesName;
                        end
                    end
                    %  make a new dir for the series
                    
                    destSeriesDir = fullfile(destSubjDir,destSeriesDirName);
                    myMkDir(destSubjDir,destSeriesDirName);
                    destFileName = [lookUpFileName(seriesName,def) def.fileExt] ;
                    destFullFilePath = fullfile(destSubjDir,destSeriesDirName,destFileName);
                    sourceImageFiles = findFiles(seriesDirs{j},def.imFileRegexp);
                    if numel(sourceImageFiles) == 1,
                        fprintf('%s -> %s \n',sourceImageFiles{1},destFullFilePath);
                        copyfile(sourceImageFiles{1},destFullFilePath);
                        if strcmp(seriesName,'DTI'),
                            % copy bval / bvec files
                            sourceBvalFile = findFiles(seriesDirs{j},'.*\.bval$');
                            sourceBvecFile = findFiles(seriesDirs{j},'.*\.bvec$');
                            destBvalFile = fullfile(destSeriesDir,'dti.bval');
                            destBvecFile = fullfile(destSeriesDir,'dti.bvec');
                            copyfile(sourceBvalFile{1},destBvalFile);
                            copyfile(sourceBvecFile{1},destBvecFile);                            
                        end
                    else
                        warning('Multiple files found in %s\n',seriesDirs{j});
                        copyfile(sourceImageFiles{1},destFullFilePath);
                   end
                end
            end
        else
            fprintf('Not in subject list, skipping ID = %s\n',id{i});
        end
    end        

function thisSeriesName=idSeries(seriesDir,def)
% id series
% figure out which series we are looking at
% 1. one file or many nii files?
seriesNames = def.seriesNames;
niiFiles = findFiles(seriesDir,def.imFileRegexp);
numNii = numel(niiFiles);
if (isempty(numNii) | numNii == 0),
    thisSeriesName = 'Empty';
else
    thisSeriesName = lookUpInfo(niiFiles,def);

    %     if ~(strcmp(thisSeriesName, seriesNames{6}) | strcmp(thisSeriesName, seriesNames{7}) | strcmp(thisSeriesName, seriesNames{8}))
%         warning('Unknown series type %s in %s for file: ',thisSeriesName,seriesDir,niiFiles{1});
%         thisSeriesName = 'Unknown';
%     end
end

function seriesName = lookUpInfo(niiFiles,def)
% compare info struct with lib
% we first check the first file in the list, 
info = fslinfo(niiFiles{1});    
info = roundNums(info);
libInfo = def.libInfo;
% gives inf struct that we can compare with
for i=1:length(libInfo)
    % fix issue w. rounding errors in pixdim
    tmpStr = roundNums(libInfo(i).dat);
    
    if isequal(info,tmpStr),
        seriesName = libInfo(i).type;
        break
    end
end
if ~exist('seriesName','var'),
    % take another check 
    % in particular the FLAIR images are messy, sometimes the correct flair image is 
    % not the first one
    
    en = rmExt(niiFiles{1});
    [~, fn ] = fileparts(en);
    seqName = fn(5:end);
    switch seqName,        
        case '_SE_IR_',
            fprintf('********* TRIGGER \n\n\n');
            % most likely a flair image, the correct file could be a *a*
            % file
            for k=1:numel(niiFiles)
            %othrFile = addInEnd(niiFiles{1},'a');
            %if exist(othrFile,'file'),
            othrFile = niiFiles{k};
                info = fslinfo(othrFile);
                info = roundNums(info);
                for i=1:length(libInfo)
                    % fix issue w. rounding errors in pixdim
                    tmpStr = roundNums(libInfo(i).dat);                    
                    if isequal(info,tmpStr),
                        seriesName = libInfo(i).type;
                        break
                    end
                end                
            end                    
    end
    if ~exist('seriesName','var'),   
        seriesName = 'Unknown'; 
    end
end

function subjList = getSubjList(subjectDeployList,def)
% return list of ids to be deployed
if strcmp(subjectDeployList,'all'),
    [~, subjList] = dirdir(def.sourceDir);
else
    chkFile(subjectDeployList);
    fid = fopen(subjectDeployList);
    if fid > 0
        cArray = textscan(fid,'%s');
        subjList=cArray{1};
    else
        error('could not open %s\n',subjectDeployList);
    end
end
        
function infoStr= roundNums(infoStr)
% fslinfo returns slightly different pixdims for the same sequences 
% presumably because of roundig errors. We tound pixdims to the nearest
% hundred.
infoStr.pixdim1 = round(infoStr.pixdim1,2);
infoStr.pixdim2 = round(infoStr.pixdim2,2);
infoStr.pixdim3 = round(infoStr.pixdim3,2);
infoStr.pixdim4 = round(infoStr.pixdim4);

function filename = lookUpFileName(seriesName,def)
% look up filename,
% new fileanmes are stored in the 'series_info.mat' file made with the
% 'mkImageInfoLib.m' script
filename = '';
libInfo = def.libInfo;
for i=1:numel(libInfo),
    if strcmp(seriesName,libInfo(i).type),
        filename = libInfo(i).rename;
    end
end
if isempty(filename),
    error('Unable to set filename for %s\n',seriesName);
end


function myMkDir(baseDir,newDir)
% check if newDir exist, make it if not
if ~exist(fullfile(baseDir,newDir),'dir'),
    mkdir(baseDir,newDir);
end



