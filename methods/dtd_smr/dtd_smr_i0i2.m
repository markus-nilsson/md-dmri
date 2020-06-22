function [i0, i2] = dtd_smr_i0i2(A)
%
% Returns il = INT[exp(-A*x^2) * Yl] for l = 0 and 2
%
A_thresh    = 1e-6;
is_low      = abs(A) < A_thresh;
%
% Constant factors from spherical integral (4*pi) and from Yl --> Pl
c0          = 4 * pi * sqrt(1 / (4 * pi)); 
c2          = 4 * pi * sqrt(5 / (4 * pi));
%
% Limiting behaviour as A --> 0
f_il_low    = @(A, n) 1/2 * (gamma(n + 1/2) / gamma(2*n + 3/2)) * (-A).^(n);
%
% Default behaviour
f_i0_high   = @(A)    sqrt(pi/4) * real(gammainc(A,1/2)./sqrt(A));
f_i2_high   = @(A)    1/2 * ( f_i0_high(A) .* ( (3 ./ (2 * A)) - 1) - (3 ./ (2 * A)) .* exp(-A));
%
% Choose behaviour
f_i0        = @(A)    is_low .* f_il_low(A,0) + ~is_low .* f_i0_high(A+eps);
f_i2        = @(A)    is_low .* f_il_low(A,1) + ~is_low .* f_i2_high(A+eps);
%
% Evaluate
i0          = c0 * f_i0(A);
i2          = c2 * f_i2(A);
end