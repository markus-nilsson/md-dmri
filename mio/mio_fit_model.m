function mfs_fn = mio_fit_model(fun, s, o_fn, opt)
% function mfs_fn = mio_fit_model(fun, s, o_fn, opt)
%
% Fits the model specified in 'fun' to the data referred to in 's', 
% and saves the output in 'o_fn', which should have '.mat' as its extension
%
% Typically, 'fun' is a local function defined within model_4d_data2fit
%
% XXX: This should be split into mdm and mio functions -- not a pure mio 
%      function now

if (nargin < 3), error('first three inputs required'); end
if (nargin < 4), opt.present = 1; end

opt = mio_opt(opt);

% Read and reformat data
[I,h]  = mdm_nii_read(s.nii_fn);
M      = mdm_mask_load(s, opt);

% Control the ranges in which the fit will be applied
M = (M > 0) .* mio_mask_ranges(M, opt.i_range, opt.j_range, opt.k_range);

h.scl_slope = 1;
h.scl_inter = 0;

% Disallow model fits to complex data
if (any(imag(I) ~= 0)), I = abs(I); end 

% Check that the mask if not just empty
if (sum(M(:)) == 0)
    error('Mask is empty -- probably something went wrong with the masking');
end

% Enable use of supplementary data
switch (opt.mio.fit_model.s_type)
    case 'smooth'
        S = mio_smooth_4d(I, opt.mio.fit_model.s_filter_sigma, opt);
    otherwise 
        S = [];
end
    
% Analyze and store output
mfs.m       = mio_volume_loop(fun, I, M, opt, S);
mfs.mask    = M;
mfs.nii_h   = h;

% Save data
mfs_fn = mdm_mfs_save(mfs, s, o_fn, opt);
