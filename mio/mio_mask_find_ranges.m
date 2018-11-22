function [i_range,j_range,k_range] = mio_mask_find_ranges(M)
% function [i_range, j_range, k_range] = mio_mask_ranges(M,opt)
%
% Detect the "bounding box" of a mask

ind = @(d1,d2) squeeze(sum( sum( M, d1), d2) > 0);

i_range = find( ind(2,3), 1, 'first'):find( ind(2,3), 1, 'last');
j_range = find( ind(1,3), 1, 'first'):find( ind(1,3), 1, 'last');
k_range = find( ind(1,2), 1, 'first'):find( ind(1,2), 1, 'last');


