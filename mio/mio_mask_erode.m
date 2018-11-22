function M = mio_mask_erode(I, n)
% function M = mio_mask_erode(I)
%
% erode the mask by 1 voxel

if (nargin < 2)
    n = 3;
end

M = convn((double(I) > 0), ones(n,n,n), 'same') >= n^3;

