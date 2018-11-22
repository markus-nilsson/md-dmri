function m = dki_lls_plot(S, xps, h, h2)
% function m = dki_lls_plot(S, xps, h, h2)

if (nargin < 4), h2 = []; end

opt = dki_lls_opt();

m     = dki_lls_1d_data2fit(S, xps, opt);
S_fit = dki_lls_1d_fit2data(m, xps)';

mgui_analysis_plot_overview(S, xps, h, h2, S_fit);

sz  = msf_size(m(1), 3);

% reshape help functions
g = @(a,n) reshape(a, prod(sz(1:3)), n);
f = @(a,n) reshape(a, sz(1), sz(2), sz(3), n);

% pull out s0
dps.s0  = m(1);

% pull out diffusion tensor, convert to parameters and add to 
% the display parameter structure (dps)
dt_1x6  = g(m(2:7), 6) * 1e9;
dps     = tm_dt_to_dps(dt_1x6, dps, f);

% pull out a kind of a covariance tensor with some elements being mixed up
% (e.g. C_xyxy is mixed with C_xxyy) (this is the kurtosis tensor)
kt_1x15 = g(m(8:22), 15) * 1e18;
dps     = tm_kt_to_dps(kt_1x15, dps, f);


title(h, sprintf('MD = %0.2f, FA = %0.2f, MK = %0.2f', dps.MD, dps.FA, dps.MK));