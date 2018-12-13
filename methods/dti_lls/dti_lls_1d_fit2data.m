function s = dti_lls_1d_fit2data(m, xps)
% function s = dti_lls_1d_fit2data(m, xps)
%
% m(1) - s0
% m(2:7) - diffusion tensor

s = m(1) * exp(-xps.bt * m(2:7)');
