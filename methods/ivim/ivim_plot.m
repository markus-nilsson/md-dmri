function m = ivim_plot(S, xps, h, h2)
% function m = ivim_plot(S, xps, h, h2)

if (nargin < 4), h2 = []; end

% ivim_check_xps(xps);
% 
% opt = ivim_opt();
% m = ivim_1d_data2fit(S, xps, opt);
% 
% S_fit = ivim_1d_fit2data(m, xps);
% 
% mgui_analysis_plot_signal(h, S, S_fit); 

fun_data2fit = @ivim_1d_data2fit;
fun_fit2data = @ivim_1d_fit2data;
opt = ivim_opt();

xps = msf_ensure_field(xps, 'b_delta', ones(size(xps.b)));
xps = msf_ensure_field(xps, 'a_ind', (1:xps.n)');

m = mplot_s_vs_b_by_b_delta(S, xps, fun_data2fit, fun_fit2data, opt, h, h2);

title(h, sprintf('f_{blood} = %2.1f prc\nD_{blood} = %1.2f um^2/ms, D_{tissue} = %1.2f um^2/ms',...
    m(2)*1e2, 1e9*m(3), 1e9*m(4)));