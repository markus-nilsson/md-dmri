function mfs_fn = color_gamma_4d_data2fit(s, mfs_fn, opt)
% function mfs_fn = color_gamma_4d_data2fit(s, o, opt)

if (nargin < 3), opt = []; end

% Loop over the volume and fit the model
xps = s.xps; % this appears to improve parallel performance
f = @(signal) color_gamma_1d_data2fit(signal, xps, opt);
mfs_fn = mio_fit_model(f, s, mfs_fn, opt);

