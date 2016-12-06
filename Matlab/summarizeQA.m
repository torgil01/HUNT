function summarizeQA(studyDir,tableFile)
% make a table of the T1 QA data
% 29.02.16: add stats on background 

opt.qaFileName = 'qaStats.mat';
qa_1='';
qa_2='';


[subjectDirs, id] = dirdir(studyDir);
tableCells = cell(numel(id),25);
for i=1:numel(id),
    if exist(fullfile(subjectDirs{i},'T1_1',opt.qaFileName),'file'),
        qa_1=fullfile(subjectDirs{i},'T1_1',opt.qaFileName);
        st{1} = load(qa_1);
        if exist(fullfile(subjectDirs{i},'T1_2',opt.qaFileName),'file'),
            qa_2=fullfile(subjectDirs{i},'T1_2',opt.qaFileName);
            st{2} = load(qa_2);
        
            tableCells(i,1:25) ={id{i},st{1}.stats.wm.mean, st{1}.stats.wm.std, st{1}.stats.wm.size,...
                st{1}.stats.gm.mean,st{1}.stats.gm.std,st{1}.stats.gm.size,...
                st{1}.stats.csf.mean,st{1}.stats.csf.std,st{1}.stats.csf.size,...
                st{1}.stats.bg.mean,st{1}.stats.bg.std,st{1}.stats.bg.size,...  
                st{2}.stats.wm.mean,st{2}.stats.wm.std,st{2}.stats.wm.size,...
                st{2}.stats.gm.mean,st{2}.stats.gm.std,st{2}.stats.gm.size,...
                st{2}.stats.csf.mean,st{2}.stats.csf.std,st{2}.stats.csf.size,...
                st{2}.stats.bg.mean,st{2}.stats.bg.std,st{2}.stats.bg.size};  
                    
        else        
            % write stats to table
            % id t1_mean_wm t1_std_wm t1_size_gm t1_mean_gm t1_std_gm
            % t1_size_gm t1_mean_csf t1_std_csf t1_size_csf
            tableCells(i,1:13) ={id{i},st{1}.stats.wm.mean,st{1}.stats.wm.std,st{1}.stats.wm.size,...
                st{1}.stats.gm.mean,st{1}.stats.gm.std,st{1}.stats.gm.size,...
                st{1}.stats.csf.mean,st{1}.stats.csf.std,st{1}.stats.csf.size,...
                st{1}.stats.bg.mean,st{1}.stats.bg.std,st{1}.stats.bg.size};
        end

    else
       % empty 
      tableCells(i,1) ={id{i}};
    end
end
% shoud use dot notation here since R markdown do not like underscore..
varNames = {'id' 't1_mean_wm' ' t1_std_wm'  't1_size_wm' ...
    't1_mean_gm'  't1_std_gm'  't1_size_gm' ...
    't1_mean_csf' 't1_std_csf' 't1_size_csf' ...
    't1_mean_bg'  't1_std_bg'  't1_size_bg' ...
    't2_mean_wm'  't2_std_wm'  't2_size_wm' ...
    't2_mean_gm'  't2_std_gm'  't2_size_gm' ...
    't2_mean_csf' 't2_std_csf' 't2_size_csf' ...
    't2_mean_bg'  't2_std_bg'  't2_size_bg'};

T = cell2table(tableCells,'VariableNames',varNames);
% save table
writetable(T,tableFile);

    
    