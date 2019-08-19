function M = mio_mask_erode(I, n)
% function M = mio_mask_erode(I)
%
% erode the mask by 1 voxel

if (nargin < 2), n = [3 3 3]; end
if (numel(n) == 1), n = [n n n]; end

M = convn((double(I) > 0), ones(n(1),n(2),n(3)), 'same') >= prod(n);

