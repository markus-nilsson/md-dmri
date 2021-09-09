function dtd_plot(S, xps, axh, axh2, opt)
% function dtd_plot(S, xps, axh, axh2)

if (nargin < 4), axh2 = []; end
if (nargin < 5), opt = []; end

opt = mdm_opt(opt);
opt = dtd_opt(opt);
opt = mplot_opt(opt);

% Customize options
opt.dtd.dmin = .02/max(xps.b);
%opt.mplot.dtd_plot_type = 'population_contour';
%[opt.dtd.dmin opt.dtd.dmax]

S = abs(S);

% Show signal and fit
m = mplot_signal_and_fit(S, xps, @dtd_1d_data2fit, @dtd_1d_fit2data, axh, opt);

% Get dps from dtd_4d_fit2param
mfs.m = zeros(1,1,1,numel(m)); mfs.m(1,1,1,:) = m;
dps = dtd_4d_fit2param(mfs.m);

%fa = tm_fa(dps.t1x6);

% Plot the tensor distribution
[dtd_1x6,w] = dtd_dist2nx6w(dtd_m2dtd(m));
mplot_dtd(dtd_1x6, w, opt.dtd.dmin, opt.dtd.dmax, axh2, opt);
mplot_dtd_addstats(dps, axh2, opt);
mplot_dtd_addtitle(dps, axh2, opt);
