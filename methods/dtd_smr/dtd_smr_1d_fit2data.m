function [s, export] = dtd_smr_1d_fit2data(m, xps, do_export)
% function s = dtd_smr_1d_fit2data(m, xps, do_export)
%
% s = s0 * [ f * Ads * At2s + (1 - f) * Adz * At2z]
%
if (nargin < 3), do_export = 0; end
export = [];

%%% Extract model parameters
s0      = m(1);
%
% Kernel
f       = m(2);
di_s    = m(3);
dd_s    = 1;
di_z    = m(4);
dd_z    = m(5);
%
% ODF
p20     = m(6);
p21r    = m(7);
p21i    = m(8);
p22r    = m(9);
p22i    = m(10);
%
% Relaxation
t2_s    = m(11);
t2_z    = m(12);
%
% Convert gradient vectors from Cartesian to Spherical
x       = xps.u(:,1);
y       = xps.u(:,2);
z       = xps.u(:,3);
[phi, theta] = cart2sph(x, y, z);
phi     = phi + pi;       % [-pi pi]  --> [0 2pi], longitude
theta   = pi / 2 - theta; % latitude  --> co-latitude

%%% Diffusion attenuation
%
%
a_s = -xps.b * di_s .* (1 - xps.b_delta * dd_s);
a_z = -xps.b * di_z .* (1 - xps.b_delta * dd_z);
%
A_s = 3 * xps.b .* xps.b_delta * di_s * dd_s;
A_z = 3 * xps.b .* xps.b_delta * di_z * dd_z;
%
[i0_s, i2_s] = dtd_smr_i0i2(A_s); % = INT[exp(-A*x^2) * Y_l], 0 to 1 (integrates over Y_l, manus definition is over L_l)
[i0_z, i2_z] = dtd_smr_i0i2(A_z); 
%
y20 = dtd_smr_spha(2,  0, theta, phi);
y21 = dtd_smr_spha(2,  1, theta, phi);
y22 = dtd_smr_spha(2,  2, theta, phi);
p2m_y2m_sum    = ...
    p20 * y20 + ...
    p21r * ( 2) * real(y21) + ...
    p21i * (-2) * imag(y21) + ...
    p22r * ( 2) * real(y22) + ...
    p22i * (-2) * imag(y22); 

y00 = 1 / sqrt(4 * pi); % By definition
p00 = 1 / sqrt(4 * pi); % ODF normalization
%
Ads     = exp(a_s) .* (i0_s * p00 * y00 * sqrt(4*pi) + i2_s .* p2m_y2m_sum * sqrt(4*pi/5));
Adz     = exp(a_z) .* (i0_z * p00 * y00 * sqrt(4*pi) + i2_z .* p2m_y2m_sum * sqrt(4*pi/5));

%%% Relaxation attenuation
%
%
At2s = exp(-xps.te/t2_s);
At2z = exp(-xps.te/t2_z);

%%% Signal
s = s0 * (f * Ads .* At2s + (1 - f) * Adz .* At2z);

%%% Export
if (do_export)
    export.a_s  = a_s;
    export.a_z  = a_z;
    export.A_s  = A_s;
    export.A_z  = A_z;
    export.i0_s = i0_s;
    export.i0_z = i0_z;
    export.i2_s = i2_s;
    export.i2_z = i2_z;
    export.y20  = y20;
    export.y21  = y21;
    export.y22  = y22;
    export.p2m_y2m_sum = p2m_y2m_sum;
    export.Ads  = Ads;
    export.Adz  = Adz;
    export.At2s = At2s;
    export.At2z = At2z;
end
end