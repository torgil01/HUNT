function doCleanup(studyDir,opt)

switch opt.cleanup,
    case 'all',        
        [hasT1_1,t1wFile] = chkSeries('T1_1',studyDir);
        if hasT1_1,
            rmFiles{1} = addInFront(t1wFile,'c1');
            rmFiles{2} = addInFront(t1wFile,'c2');
            rmFiles{3} = addInFront(t1wFile,'c3');
            rmFiles{4} = addInFront(t1wFile,'c4');
            rmFiles{5} = addInFront(t1wFile,'c5');
            tmpName = addInEnd(t1wFile,'_seg8');
            rmFiles{6} = replaceExt(tmpName,'.mat');            
            deleteFiles(rmFiles);
        end
            
        [hasT1_2, t1wFile] = chkSeries('T1_2',studyDir);
        if hasT1_2,
            rmFiles{1} = addInFront(t1wFile,'c1');
            rmFiles{2} = addInFront(t1wFile,'c2');
            rmFiles{3} = addInFront(t1wFile,'c3');
            rmFiles{4} = addInFront(t1wFile,'c4');
            rmFiles{5} = addInFront(t1wFile,'c5');
            tmpName = addInEnd(t1wFile,'_seg8');
            rmFiles{6} = replaceExt(tmpName,'.mat');
            deleteFiles(rmFiles);
        end
    
    case 'seg8',        
        [hasT1_1,t1wFile] = chkSeries('T1_1',studyDir);
        if hasT1_1,
            tmpName = addInEnd(t1wFile,'_seg8');
            rmFiles{1} = replaceExt(tmpName,'.mat');            
            deleteFiles(rmFiles);
        end
            
        [hasT1_2, t1wFile] = chkSeries('T1_2',studyDir);
        if hasT1_2,
            tmpName = addInEnd(t1wFile,'_seg8');
            rmFiles{1} = replaceExt(tmpName,'.mat');
            deleteFiles(rmFiles);
        end            
end


function deleteFiles(fileList)
for i=1:numel(fileList),
    delete(fileList{i});
end
