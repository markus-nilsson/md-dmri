function dist_s = dist_1d_discrete2smooth(dist_d,dist_s)
% function dist_s = dist_1d_discrete2smooth(dist_d,dist_s)
%
% Convert from discrete to smooth 1D distribution. Gaussian convolution.
%
% dist_d discrete distribution  with fields
% dist_d.n number of discrete components
% dist_d.x vector of x-values
% dist_d.w vector of weights
% dist_s smooth distribution  with input fields
% dist_s.x vector of x-values
% dist_s.xsigma std for Gaussian convolution x
% dist_s output smooth distribution with additional fields
% dist_s.w matrix of weights

n0 = dist_d.n;
x0 = dist_d.x(:); x0(~isfinite(x0)) = 0;
w0 = dist_d.w(:); w0(~isfinite(w0)) = 0;

x = dist_s.x(:);
xsigma = dist_s.xsigma;
nx = numel(x);

dx = x(2)-x(1);

x_k = repmat(x(:),[1 n0]);
x0_k = repmat(x0(:)',[nx 1]);
k = 1/(xsigma*sqrt(2*pi)).*exp(-(x_k-x0_k).^2/(2*xsigma^2));

p = k*w0;

dist_s.w = p;
