function M = mio_mask_expand(I, n, opt)
% function M = mio_mask_expand(I, opt)
%
% expand the mask by n voxels

if (nargin < 2), n = 1; end
if (nargin < 3), opt.present = 1; end
opt = mio_opt(opt);





switch (opt.mask.expand.method)
    case 1
        n = 2*n + 1;
        M = convn((I > 0), ones(n,n,n), 'same') > 0;
        
    case 2
        M = (I > 0);
        for c = 1:n
            M = mio_smooth_4d( double(M), opt.mask.expand.sigma);
            M = M > opt.mask.expand.threshold;
        end
end

