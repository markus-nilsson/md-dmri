function s = dki_lls_1d_fit2data(m, xps)
% function s = dki_lls_1d_fit2data(m, xps)
%
% m(1)    - s0
% m(2:7)  - diffusion tensor 
% m(8:22) - fourth order fully symmetric kurtosis tensor with 15 elements

% need the outer product of the b-tensor 
bt2 = tm_1x3_to_1x15(xps.u) .* repmat(xps.b.^2, 1, 15);

% define data from fitted parameters
s = m(1) * exp(-xps.bt * m(2:7) + 0.5 * bt2 * m(8:22));
