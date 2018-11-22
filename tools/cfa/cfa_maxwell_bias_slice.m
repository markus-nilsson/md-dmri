function [c, k_s] = cfa_maxwell_bias_slice(k, v_s, r, st, k0)
% function [c, k_s] = cfa_maxwell_bias_slice(k, v_s, r, st)
%
% Baron et al., The effect of concomitant gradient fields on diffusion 
% tensor imaging. Magn Reson Med, 2012. 68(4): p. 1190-201.
% 
% v_s is the normal vector to the slice
% r   is nx3 position vector (location of center of voxels where origo is
%     iso center.
% st  is the slice thickness

if nargin < 5 || isempty(k0)
    k0 = [0 0 0]';
end

if (st == 0)
    c   = ones(size(r,1),1);
    k_s = zeros(size(r,1),1);
    return;
end

% Make sure that the slice vector is length 1
v_s = v_s / sqrt(sum(v_s.^2));

% Project k onto v_s and location
k_s = v_s * (k * r' + k0);

% Bias for box-shaped slice selection
c = abs(sinc(k_s * st));
