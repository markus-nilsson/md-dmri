function m = dki_pa_plot(S, xps, h, h2, opt)
% function m = dki_pa_plot(S, xps, h, h2)

if (nargin < 5), opt = []; end
if (nargin < 4), h2 = []; end

if (~isfield(xps, 'b_delta')), xps.b_delta = ones(size(xps.b)); end

m = mplot_s_vs_b_by_b_delta(S, xps, ...
    @dki_pa_1d_data2fit, @dki_pa_1d_fit2data, @dki_pa_opt, h, h2);


MD = m(2) * 1e9;
MK = 3 * m(3) / m(2)^2;

title(h, sprintf('MD = %0.2f, MK = %0.2f', MD, MK));