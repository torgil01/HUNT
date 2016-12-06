function logfile(varargin)
% write to logfile
persistent fid;
if nargin == 1,
    action = varargin{1};
else
    action = varargin{1};
    string = varargin{2};
end

switch action,
    case 'init',
        fid = fopen(string,'a+');
    case 'write',
        fprintf(fid,string);
    case 'close',
        fclose(fid);
end
