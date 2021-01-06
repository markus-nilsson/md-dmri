function s = ning18_1d_fit2data(m, xps)
% function s = ning18_1d_fit2data(m, xps)
%
% m(1) - S0
% m(2) - MD
% m(3) - V
% m(4) - Vk

% Derive effective exchange time
t_ex    = ning18_1d_xps2tex(xps);

% Define signal
s       = m(1) * exp(-xps.b * m(2) + (1/2) * xps.b.^2 * m(3) + (-1/2) * t_ex .* xps.b.^2 * m(4));