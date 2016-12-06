% do linkage
% 
% M is in lower triangular form, need to convert it to a linear index
% the "squareform" command can do this
% ie. linA = squareform(matA)
%     matA = squareform(linA)
% Neat!
% 
% but matA must be symmetric
Mat = M(:,:,3);
sMat = Mat + Mat';
% convert to linear vector
linMat = squareform(sMat);
dissVec = (max(sMat(:))- linMat)./max(sMat(:)); 
% Ok, so "linMat" is now our distance vector
% as in : http://se.mathworks.com/help/stats/hierarchical-clustering.html
%
% Next we do the linkage which groups the distance matrix into clusters
Z = linkage(dissVec,'complete');
cutoff=0.2;
groups = cluster(Z,'cutoff',cutoff,'criterion','distance');
figure, dendrogram(Z,0,'colorthreshold',cutoff);


% lind = sub2ind([5,5],4,2)