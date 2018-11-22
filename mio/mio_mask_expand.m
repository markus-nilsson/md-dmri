function M = mio_mask_expand(I, n, opt)
% function M = mio_mask_expand(I, opt)
%
% expand the mask by n voxels

if (nargin < 2), n = 1; end
if (nargin < 3), opt.present = 1; end
opt = mdm_opt(opt);

n = 2*n + 1;

M = convn((I > 0), ones(n,n,n), 'same') > 0;

