function M = mio_mask_threshold(I, opt, threshold, ind)
% function M = mio_mask_threshold(I, opt, threshold, ind)
%
% Masks an image by 
% 1. Thresholding the b0 image
% 2. Filling empty spaces in the mask
% 3. Expanding, filling, and eroding
% 4. Discarding all but the largest connected component
%
% Input arguments
% I   - the image volume (mandatory)
% opt - options structure, two arguments are used (optional)
%            opt.mask.b0_ind - point to the b0 images for thresholding
%            opt.mask.threshold - threshold in percent of max
%
% threshold - overrides opt.mask.threshold (optional)
% ind       - overrides opt.mask.b0_ind (optional)

if (nargin < 2), opt.mask.present = 1; end

opt = mio_opt(opt);

if (nargin < 3), threshold = opt.mask.threshold; end
if (nargin < 4), ind = opt.mask.b0_ind; end

% Disallow model fits to complex data
if (any(imag(I) ~= 0)), I = abs(I); end 

% define the mask from threshold of b0 image
I0 = mean(I(:,:,:,ind),4);

M = single(I0) > (threshold * single(quantile(I0(:),0.99)));

M = mio_mask_fill(M);
M = mio_mask_expand(M, 1);
M = mio_mask_fill(M);
M = mio_mask_erode(M, 1);
M = mio_mask_keep_largest(M);

