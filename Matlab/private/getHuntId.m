function id= getHuntId(indx,QA)
% return ID in array
if isempty(indx),
    id =[];
else
    for i=1:length(indx),
        id(i) =   str2num(QA(indx(i)).id) - 9410000000000;
    end
end
