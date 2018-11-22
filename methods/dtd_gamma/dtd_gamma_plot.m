function dtd_gamma_plot(S, xps, h, h2)
% function dtd_gamma_plot(S, xps, h, h2)

if (nargin < 3), h  = gca; end
if (nargin < 4), h2 = []; end

m = mplot_s_vs_b_by_b_delta(S, xps, ...
    @dtd_gamma_1d_data2fit, @dtd_gamma_1d_fit2data, @dtd_gamma_opt, h, h2);

S0 = m(1);
MD = m(2) / 1e-9;

MKi = 3*m(3)/(m(2)^2);
MKa = 3*m(4)/(m(2)^2);

Vl = 5/2 * m(4);

uFA = sqrt(3/2) * sqrt( Vl ./ (Vl + m(3) + m(2).^2) );

title_str = {...
    ['S_0 = ' num2str(S0, 2) '   MD = ' num2str(MD, 2) ' um^2/ms']; ...
    ['MK_I = ' num2str(MKi, 2) '   MKa = ' num2str(MKa, 2) '   uFA = ' num2str(uFA, 2)]};

title(h, title_str)