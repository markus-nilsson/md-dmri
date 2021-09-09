function xps = mdm_xps_from_gdir(gdir_fn, delimeter, b_delta)
% function xps = mdm_xps_from_gdir(gdir_fn, delimeter, b_delta)
%
% read a gradient textfile in the Lund format, which is defined as follows
%   n_x, n_y, n_z, b
%
% units of b are in s/mm2, i.e., b = 1000 s/mm2 for a standard DTI
%
% the xps is always in SI units
%
% optional arguments
% delimeter, asumed to be ',' unless specified
% b_delta, assumed to be 1 unless specified (e.g. PGSE / LTE / SDE)

if (nargin < 2), delimeter = []; end
if (nargin < 3), b_delta = 1; end

if (isempty(delimeter)), delimeter = ','; end
if (b_delta < -0.5) || (b_delta > 1), error('b_delta out of range'); end

if (~exist(gdir_fn, 'file')), error('Did not find file %s', gdir_fn); end

% read text and split by delimeter, keeping only non-empty entries to solve
% problems of multiple consequtive delimeters such as spaces
txt = mdm_txt_read(gdir_fn);
f = @(x) x(~cellfun(@isempty, x));

try
    tmp = cellfun(@(x) strsplit(x, delimeter), txt(:), 'uniformoutput', 0);
    tmp = cellfun(f, tmp, 'uniformoutput', 0);
    tmp = cellfun(@(x) str2double(x), tmp, 'uniformoutput', 0);
    tmp = cell2mat(tmp)';
    
    if any(isnan(tmp))
        error('Bad format')
    end
    
catch
    clear tmp
    for i = 1:numel(txt)
        tmp(i,:) = str2double( strsplit(txt{i}));
    end
    
    tmp = tmp';
end


% compile the output
b = tmp(4,:)' * 1e6;
u = tmp(1:3,:)';


% Make a trick to ensure that tensor shapes survives the tensor
% computations
u_norm = u;
u_norm(:, 1) = u_norm(:, 1) + 0.00001;
u_norm = u_norm ./ repmat(eps + sqrt(sum(u_norm.^2,2)), 1, 3);

if (size(u,1) ~= numel(b)), error('b and u are different lengths'); end

% compute b-tensors from b-values, b_delta value(s) and symmetry axis
bt  = tm_tpars_to_1x6(b + 0.001, b_delta, u_norm);
xps = mdm_xps_from_bt(bt);

% store the direction as well
xps.u = u;

