function  flirtResample(input,reference,output)
% Resample image to ref using flirt 
% note ths fails if the data ordring is different!
if ~exist(input,'file'),
    error('input file %s not found, exiting',file);
end
if ~exist(reference,'file'),
    error('refernce file %s not found, exiting',file);
end

idFile = tempname;
id = eye(4);
writeMat(id,idFile)
[err,output] = system(sprintf('flirt -in %s -ref %s -out %s -init %s -applyxfm ',input,reference,output,idFile));
if err ~= 0,
    error('Error in flirtResample.m (flirt wrapper); output from command:\n %s\n',output);
end
delete(idFile);


function writeMat(mat,fname)
fid=fopen(fname,'w');
fprintf(fid,'%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n',mat);
fclose(fid);