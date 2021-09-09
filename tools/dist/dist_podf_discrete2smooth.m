function odf_s = dist_podf_discrete2smooth(odf_d,odf_s)
% function odf_s = dist_podf_discrete2smooth(odf_d,odf_s)
%
% Convert from discrete to smooth 2D odf. Gaussian convolution.
%
% odf_d discrete odf with fields
% odf_d.n number of discrete components
% odf_d.x vector of x-values
% odf_d.y vector of y-values
% odf_d.w vector of weights
% odf_s smooth odf  with input fields
% odf_s.x vector of x-values
% odf_s.y vector of y-values
% odf_s.kappa std for Gaussian convolution
% odf_s output smooth odf with additional fields
% odf_s.w matrix of weights
% odf_s.verts vertices
% odf_s.c color


[K.x_s,K.x_d] = ndgrid(odf_s.x,odf_d.x);
[K.y_s,K.y_d] = ndgrid(odf_s.y,odf_d.y);
[K.z_s,K.z_d] = ndgrid(odf_s.z,odf_d.z);

k = exp(odf_s.kappa*(K.x_s.*K.x_d + K.y_s.*K.y_d + K.z_s.*K.z_d).^2);

clear K

odf_s.w = k*odf_d.w;
odf_s.diso = (k*(odf_d.w.*odf_d.diso))./odf_s.w;
odf_s.sddelta = (k*(odf_d.w.*odf_d.sddelta))./odf_s.w;
odf_s.r2 = (k*(odf_d.w.*odf_d.r2))./odf_s.w;
odf_s.verts = repmat(odf_s.w,[1 3]).*[odf_s.x odf_s.y odf_s.z];
odf_s.c = abs([odf_s.x odf_s.y odf_s.z]);

odf_s.w(~isfinite(odf_s.w)) = 0;
odf_s.diso(~isfinite(odf_s.diso)) = 0;
odf_s.sddelta(~isfinite(odf_s.sddelta)) = 0;
odf_s.r2(~isfinite(odf_s.r2)) = 0;
