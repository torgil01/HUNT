function M = mkCorrelMatrix(imDir)
% make a N x N correlation matrix from files
img = findFiles(imDir,'^im_.*.nii');
N=numel(img);
M = zeros(N,N,4);
metric = {'mi','ecc','nmi','ncc'};
k=1;
for i=1:N
    VG = spm_vol(img{i});
    VG.uint8 = loaduint8(VG);
    for j=i+1:N          
        VF = spm_vol(img{j});     
        VF.uint8 = loaduint8(VF);
        parfor k=1:4,
            M(i,j,k) = myspm_imageSimilarity(VG,VF,metric{k});  
        end
    end
end

        
