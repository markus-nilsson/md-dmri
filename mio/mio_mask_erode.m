function M = mio_mask_erode(I,sz)
% function M = mio_mask_erode(I)
%
% erode the mask by 1 voxel

if (nargin < 2)
    n = 3;
    sz = [n n n];
end


M = convn((double(I) > 0), ones(sz(1),sz(2),sz(3)), 'same') >= prod(sz);

