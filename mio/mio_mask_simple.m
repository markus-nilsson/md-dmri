function M = mio_mask_simple(I, opt)
% function M = mio_mask_simple(I, opt)
%
% creates a mask in a very simple way by looking a signal variation along
% the fourth dimension

if (nargin < 2), opt.present = 1; end

opt = mio_opt(opt);

% define the mask from the variation of the signal
I_mean = nanmean(single(abs(I)), 4);
I_mean = imfilter(I_mean, ones(5,5,1) / 5^2);

I_V = zeros(size(I_mean));
for c = 1:size(I,4)
    I_V = I_V + (single(abs(I(:,:,:,c))) - imfilter(single(abs(I(:,:,:,c))), ones(5,5,1) / 5^2)).^2;
end
I_V = I_V / size(I,4);

M = (I_mean ./ sqrt(I_V)) > opt.mask.simple_threshold; % empirical limit

M = imfilter(single(M), ones(3,3,3)) > 10; % get rid of lonely voxels
M = imfilter(single(M), ones(3,3,3)) > 0;  % fill up the edges

M = mio_mask_fill(M,3);
M = mio_mask_fill(M,2);
M = mio_mask_fill(M,1);
M = mio_mask_fill(M,2);
M = mio_mask_fill(M,3);
M = mio_mask_keep_largest(M);
