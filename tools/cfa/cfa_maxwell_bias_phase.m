function [c, k_p] = cfa_maxwell_bias_phase(k, v_p, r, T2star, p_vel, k0)
% function [c, k_p] = cfa_maxwell_bias_phase(k, v_p, r, T2star, p_vel)
%
% Baron et al., The effect of concomitant gradient fields on diffusion 
% tensor imaging. Magn Reson Med, 2012. 68(4): p. 1190-201.
%
% v_p    is the phase direction vector
% T2Star is the T2* relaxation time of the tissue
% p_vel  is the k-space velocity in the phase direction
% r      is nx3 position vector (location of center of voxels where origo is
%        iso center.

if nargin < 6 || isempty(k0)
    k0 = [0 0 0]';
end

if isinf(T2star)
    c   = ones(size(r,1),1);
    k_p = zeros(size(r,1),1);
    return
end

% Make sure that the phase vector is length 1
v_p = v_p / sqrt(sum(v_p.^2));

% Project k onto v_p and location
k_p = v_p * (k * r' + k0);

% Bias due to slice dephasing for tissue with single T2* time
c =  exp(-abs(k_p) / (p_vel * T2star) );