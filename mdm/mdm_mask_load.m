function M = mdm_mask_load(s, opt)
% function M = mdm_mask_load(s, opt)
%
% Load the mask from s.mask_fn
%
% Optionally, mask using i_range, j_range and k_range in opt

if (nargin < 2), opt.present = 1; end
opt = mdm_opt(opt);

h = mdm_nii_read_header(s.nii_fn);

sz = h.dim(2:4)';

if (~isfield(s, 'mask_fn'))
    M = ones(sz); 
else
    M = mdm_nii_read(s.mask_fn);
    
    if (size(M,1) ~= sz(1)) || (size(M,2) ~= sz(2)) || (size(M,3) ~= sz(3))
        error(['Size of mask different from data (' num2str(size(M)) ' vs ' num2str(sz)]);
    end
end

