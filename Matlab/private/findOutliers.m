function indx = findOutliers(X,nStd)
% find outliers in vector / matrix X
% return index of values that are more than N std from mean
% if input is vector we assume that each element is a observation form one ID
% if the input is a matrix we assume that each row is from a ID

[nId,nObs] = size(X);
if nObs == 1,
    % remove min/max from mean 
    indxU = find(X > (median(X)+nStd*std(X)));
    indxL = find(X < (median(X)-nStd*std(X)));
    indx =sort([indxU' indxL']);
%     
%     Z = zscore(X);
%     indx = find(abs(Z) > nStd);
else
    % we compare to the total mean
    medianX = median(X(:));
    stdX = std(X(:));  
    count=0;
    indx=[];
    for i=1:nId,                   
        indxU = find(X(i,:) > (medianX+nStd*stdX)); % cmp to glob median/std
        indxL = find(X(i,:) < (medianX-nStd*stdX));
        if (any(indxU) || any(indxL)),
            count=count+1;
            indx(count)=i;
        end
    end
end
