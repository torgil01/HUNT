function dumpCoregData(pinfo,tableFile)


tableCells = cell(numel(pinfo),7);
for i=1:numel(pinfo),
    tableCells(i,1:7) = {pinfo{i}.id,pinfo{i}.coregT1_mni,pinfo{i}.coregT1_T1Other,...
            pinfo{i}.coregT1_dti,pinfo{i}.coregT1_flair,pinfo{i}.refT1_brain,...
            pinfo{i}.otherT1_brain};
        
end

varNames={'id','coregT1_mni','coregT1_T1Other','coregT1_dti','coregT1_flair','refT1_brain',...
    'otherT1_brain'}
T = cell2table(tableCells,'VariableNames',varNames);
% save table
writetable(T,tableFile);