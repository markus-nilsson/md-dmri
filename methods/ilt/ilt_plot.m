function ilt_plot(S, xps, h, h2, opt)
% function dtd_ndi_plot(S, xps, h, h2, opt)

if (nargin < 4), h2 = []; end

% ind = xps.b_delta > 0.95; % Linear encoding
% ind = ((xps.b_delta < 0.1) & (xps.b_delta > -0.1)); % Spherical encoding
% ind = (xps.b_delta < -0.45); % Planar encoding
% ind = (xps.b_delta < -0.45) | (xps.b_delta > 0.95) | ((xps.b_delta < 0.1) & (xps.b_delta > -0.1)); % All

% S = S(ind);
% xps = mdm_xps_subsample(xps, ind);

m = mplot_s_vs_b_by_b_delta_ilt(S, xps, @ilt_1d_data2fit, @ilt_1d_fit2data, @ilt_opt, h, h2);