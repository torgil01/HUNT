function im = invBinarize(im,thr)
% binarize and invert image on thr
im(im < thr) =0;
im(im >= thr) = 1;
im = ~im;


