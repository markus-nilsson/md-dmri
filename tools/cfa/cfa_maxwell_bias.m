function [c, c_s, c_p] = cfa_maxwell_bias(gwf, rf, dt, ips, do_k0)
% function [c, c_s, c_p] = cfa_maxwell_bias(gwf, rf, dt, ips, do_k0)
%
% gwf - gradient waveform of size n x 3
% rf  - effect of rf, size 1 x 3
% dt  - time step
% ips - imaging parameter structure (see function "csf_ips_example")
%
% Baron et al., The effect of concomitant gradient fields on diffusion
% tensor imaging. Magn Reson Med, 2012. 68(4): p. 1190-201.

if nargin < 5
    do_k0 = 1;
end

cfa_check_ips(ips);

[k1, k0]   = cfa_maxwell_k_matrix(gwf, rf, dt, ips.B0);

if ~do_k0
    k0 = [0 0 0]';
end

c_s = cfa_maxwell_bias_slice(k1, ips.o(3,:), ips.r_xyz, ips.res(3), k0);
c_p = cfa_maxwell_bias_phase(k1, ips.o(2,:), ips.r_xyz, ips.T2s, ips.kpv, k0);

% Total bias is the product of phase and slice biases
c   = c_s .* c_p;



