function replaceHdr(file,ref)
% replace image hader

zipFile = false;
zipRef = false;
extFile = getExt(file);
extRef = getExt(ref);

if strcmp(extFile,'.nii.gz'),
    zipFile = true;
    gunzip(file);
    delete(file);
    file = replaceExt(file,'.nii');
end

if strcmp(extRef,'.nii.gz'),
    zipRef = true;
    gunzip(ref);
    delete(ref);
    ref = replaceExt(ref,'.nii');
end

Vref = spm_vol(ref);
Vfile = spm_vol(file);
img = spm_read_vols(Vfile);
Vnew = rmfield(Vref,'pinfo');
Vnew.fname = Vfile.fname;
spm_write_vol(Vnew,img);

if zipFile,    
    gzip(file);
    delete(file);
end

if  zipRef,   
    gzip(ref);
    delete(ref);
end




