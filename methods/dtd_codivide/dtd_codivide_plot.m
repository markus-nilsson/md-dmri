function m = dtd_codivide_plot(S, xps, h, h2, opt)
% function m = dtd_codivide_plot(S, xps, h, h2)

if (nargin < 5), opt = []; end
if (nargin < 4), h2 = []; end

m = mplot_s_vs_b_by_b_delta(S, xps, ...
    @dtd_codivide_1d_data2fit, @dtd_codivide_1d_fit2data, @dtd_codivide_opt, h, h2);




title(h, sprintf('v(at) = %0.2f, v(fw) = %0.2f, mdt = %0.2f', m(2), m(3), m(4) * 1e9));