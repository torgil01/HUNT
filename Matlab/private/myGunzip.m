function myGunzip(file)
% wrapper for pigz
cmd = sprintf('pigz -k -d -p 8 %s',file);
system(cmd);
