function m = dti_lls_plot(S, xps, h, h2)
% function m = dti_lls_plot(S, xps, h, h2)

if (nargin < 4), h2 = []; end

dti_lls_check_xps(xps);

opt = dti_lls_opt;
m = dti_lls_1d_data2fit(S, xps, opt);

dt = m(:,2:7);
pars = tm_1x6_to_tpars(dt);

S_fit = dti_lls_1d_fit2data(m, xps);

mgui_analysis_plot_overview(S, xps, h, h2, S_fit);


title(h, sprintf('MD = %0.2f um^2/ms, FA = %0.2f', ...
    pars.trace/3 * 1e9, pars.fa));