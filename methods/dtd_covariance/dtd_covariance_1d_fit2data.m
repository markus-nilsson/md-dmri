function s = dtd_covariance_1d_fit2data(m, xps)
% function s = dtd_covariance_1d_fit2data(m, xps)
%
% m(1)    - s0
% m(2:7)  - diffusion tensor 
% m(8:28) - fourth order covariance
%
% size(m) = 1x28

% need the outer product of the b-tensor 
bt2 =  tm_1x6_to_1x21(xps.bt);

% define data from fitted parameters
s = m(1) * exp(-xps.bt * m(2:7)' + 0.5 * bt2 * m(8:28)');
