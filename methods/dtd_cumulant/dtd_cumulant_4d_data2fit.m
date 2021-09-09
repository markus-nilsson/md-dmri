function mfs_fn = dtd_cumulant_4d_data2fit(s, mfs_fn, opt, ind)
% function mfs_fn = dtd_cumulant_4d_data2fit(s, mfs_fn, opt, ind)
% 
% s         - structure with two fields pointing to data (s.nii_fn and s.xps)
% mfs_fn    - model fit structure filename
% opt       - options (optional)
% ind       - singal indices used to fit the model (optional)

if (nargin < 3), opt = []; end
if (nargin < 4), ind = ones(s.xps.n,1) > 0; end

% Loop over the volume and fit the model
xps     = s.xps; % this appears to improve parallel performance
f       = @(signal) dtd_cumulant_1d_data2fit(signal, xps, opt, ind);
mfs_fn  = mio_fit_model(f, s, mfs_fn, opt);

