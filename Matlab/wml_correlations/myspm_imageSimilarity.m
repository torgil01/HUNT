% 
function si = myspm_imageSimilarity(VG,VF,metric) 

flags.sep = [2]; 
flags.tol = [0.001];
flags.params = [0];

vxg      = sqrt(sum(VG.mat(1:3,1:3).^2));
fwhmg    = sqrt(max([1 1 1]*flags.sep(end)^2 - vxg.^2, [0 0 0]))./vxg;
VG       = smooth_uint8(VG,fwhmg); % Note side effects

sc = flags.tol(:)'; % Required accuracy
sc = sc(1:length(flags.params));
xi = diag(sc*20);
x = zeros(numel(VF),numel(flags.params));



vxf       = sqrt(sum(VF.mat(1:3,1:3).^2));
fwhmf     = sqrt(max([1 1 1]*flags.sep(end)^2 - vxf.^2, [0 0 0]))./vxf;
VF       = smooth_uint8(VF,fwhmf); % Note side effects

s=[1,1,1];
si = optfun(1,VG,VF,s,metric);


%==========================================================================
% function o = optfun(x,VG,VF,s,cf,fwhm)
%==========================================================================
function o = optfun(x,VG,VF,s,cf,fwhm)
% The function that is minimised.
if nargin<6, fwhm = [7 7];   end
if nargin<5, cf   = 'mi';    end
if nargin<4, s    = [1 1 1]; end

% x     - the parameters describing the rigid body rotation, such that a
%         mapping from voxels in G to voxels in F is attained by:
%         VF.mat\spm_matrix(x(:)')*VG.mat

% Voxel sizes
vxg = sqrt(sum(VG.mat(1:3,1:3).^2));sg = s./vxg;

% Create the joint histogram
H = spm_hist2(VG.uint8,VF.uint8, VF.mat\spm_matrix(x(:)')*VG.mat ,sg);

% Smooth the histogram
% lim  = ceil(2*fwhm);
% krn1 = spm_smoothkern(fwhm(1),-lim(1):lim(1)) ; krn1 = krn1/sum(krn1); H = conv2(H,krn1);
% krn2 = spm_smoothkern(fwhm(2),-lim(2):lim(2))'; krn2 = krn2/sum(krn2); H = conv2(H,krn2);

% Compute cost function from histogram
H  = H+eps;
sh = sum(H(:));
H  = H/sh;
s1 = sum(H,1);
s2 = sum(H,2);

switch lower(cf)
    case 'mi'
        % Mutual Information:
        H   = H.*log2(H./(s2*s1));
        mi  = sum(H(:));
        o   = mi;
    case 'ecc'
        % Entropy Correlation Coefficient of:
        % Maes, Collignon, Vandermeulen, Marchal & Suetens (1997).
        % "Multimodality image registration by maximisation of mutual
        % information". IEEE Transactions on Medical Imaging 16(2):187-198
        H   = H.*log2(H./(s2*s1));
        mi  = sum(H(:));
        ecc = -2*mi/(sum(s1.*log2(s1))+sum(s2.*log2(s2)));
        o   = ecc;
    case 'nmi'
        % Normalised Mutual Information of:
        % Studholme,  Hill & Hawkes (1998).
        % "A normalized entropy measure of 3-D medical image alignment".
        % in Proc. Medical Imaging 1998, vol. 3338, San Diego, CA, pp. 132-143.
        nmi = (sum(s1.*log2(s1))+sum(s2.*log2(s2)))/sum(sum(H.*log2(H)));
        o   = nmi;
    case 'ncc'
        % Normalised Cross Correlation
        i     = 1:size(H,1);
        j     = 1:size(H,2);
        m1    = sum(s2.*i');
        m2    = sum(s1.*j);
        sig1  = sqrt(sum(s2.*(i'-m1).^2));
        sig2  = sqrt(sum(s1.*(j -m2).^2));
        [i,j] = ndgrid(i-m1,j-m2);
        ncc   = sum(sum(H.*i.*j))/(sig1*sig2);
        o     = ncc;
    otherwise
        error('Invalid cost function specified');
end






