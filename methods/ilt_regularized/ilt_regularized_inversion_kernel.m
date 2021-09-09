function [M, D, dD, A] = ilt_regularized_inversion_kernel(xps,opt)

if nargin < 2
    opt = mdm_opt();
    opt = mdm_opt(ilt_regularized_opt);
end

% Extract b-values
b = xps.b;

% Sample diffusivities to build the inversion kernel matrix
dmin = opt.ilt_regularized.dmin;
dmax = opt.ilt_regularized.dmax;
M = opt.ilt_regularized.sample_number_D;
%D = linspace(dmin,dmax,M+1)';
D = logspace(log10(dmin),log10(dmax),M+1)';
dD = diff(D);
D = D(1:M) + dD/2;
dD = 1e-10*ones(M,1);

% Build inversion kernel matrix
[~,Darray] = ndgrid(b,D);
[barray,dDarray] = ndgrid(b,dD);
A = 1./Darray.*dDarray.*exp(-barray.*Darray);
