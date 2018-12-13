function s = ivim_1d_fit2data(m, xps)
% function s = ivim_1d_fit2data(m, xps)
%
% simple biexponential model
% m(1) - s0
% m(2) - fraction of fast
% m(3) - fast diffusivity
% m(4) - slow diffusivity

s = m(1) * (m(2) * exp(-xps.b * m(3)) + (1 - m(2)) * exp(-xps.b * m(4)));
