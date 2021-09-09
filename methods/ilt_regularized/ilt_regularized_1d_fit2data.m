function s = ilt_regularized_1d_fit2data(PD, xps)

[~, D, dD, A] = ilt_regularized_inversion_kernel(xps);

s = A*PD;
I0 = sum(PD./D.*dD);
s = s/I0;