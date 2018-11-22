function M = mio_mask_ranges(I, i_range, j_range, k_range)
% function M = mio_mask_ranges(I,i_range, j_range, k_range)
%
% Apply a "bounding box" as the mask

if (nargin < 2) || (isempty(i_range)), i_range = 1:size(I,1); end
if (nargin < 3) || (isempty(j_range)), j_range = 1:size(I,2); end
if (nargin < 4) || (isempty(k_range)), k_range = 1:size(I,3); end

M = zeros(size(I));
M(i_range, j_range, k_range) = 1;

M = M > 0;




