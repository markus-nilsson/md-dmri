function [k1, k0] = cfa_maxwell_k_matrix(gwf, rf, dt, B0)
% function k = cfa_maxwell_k_matrix(gwf, rf, dt, B0)
% 
% k    - matrix that determines size of the effect of maxwell terms.
% gwf  - gradient waveform, size n x 3 
% rf   - effect of gradient waveform, n x 1 
% 
% References:
% Bernstein et al., Concomitant gradient terms in phase contrast MR: 
% analysis and correction. Magn Reson Med, 1998. 39(2): p. 300-8.
% 
% Baron et al., The effect of concomitant gradient fields on diffusion 
% tensor imaging. Magn Reson Med, 2012. 68(4): p. 1190-201.
%
% Szczepankiewicz and Nilsson, Maxwell-compensated waveform design for 
% asymmetric diffusion encoding. ISMRM, 2018, Paris, France
% Download abstract at: https://goo.gl/vVGQq2

Gx = gwf(:,1);
Gy = gwf(:,2);
Gz = gwf(:,3);


t0 = [sum(Gx.*rf.*dt), sum(Gy.*rf.*dt), sum(Gz.*rf.*dt)]';


t1 = [
       sum(Gz.*Gz.*rf.*dt),                         0,                          -2*sum(Gx.*Gz.*rf.*dt)  ;
                         0,       sum(Gz.*Gz.*rf.*dt),                          -2*sum(Gy.*Gz.*rf.*dt)  ;
    -2*sum(Gx.*Gz.*rf.*dt),    -2*sum(Gy.*Gz.*rf.*dt),    4*(sum(Gx.*Gx.*rf.*dt) + sum(Gy.*Gy.*rf.*dt)) ;
    ];

k0 = msf_const_gamma / 2 / pi * t0;

k1 = msf_const_gamma / 2 / pi * t1 / (4 * B0);

