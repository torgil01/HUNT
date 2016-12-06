function QA= collect_dti_qa(subjDir)
% collect QA struct previously calculated with dtiQA.m
qa = findFiles(subjDir,'QA.mat');
for i=1:numel(qa),
    load(qa{i});
    QA(i) = qa1;
end
