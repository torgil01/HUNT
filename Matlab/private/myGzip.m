function myGzip(file)
% wrapper for pigz
cmd = sprintf('pigz -k -p 8 %s',file);
system(cmd);
