function [m,cond] = dki_lls_1d_data2fit(signal, xps, opt, ind)
% function [m,cond] = dki_lls_1d_data2fit(signal, xps, opt, ind)
%
% fit the DKI model using linear least squares 

% Exclude data points with zero or negative values
if (nargin < 4), ind = ones(size(signal)) > 0; end
ind = ind & (signal > 0);

% Setup regressors for diffusion tensor distribution (DTD) model
b0 = ones(xps.n, 1);
b0 = b0(ind);
b2 = xps.bt(ind,:) * 1e-9 ;   % SI unit conversion
b4 = tm_1x3_to_1x15(xps.u(ind,:)) .* repmat(xps.b(ind).^2 * 1e-18, 1, 15);
    
X = [b0 -b2 1/2 * b4];
    
if (opt.dki_lls.do_heteroscedasticity_correction)
    C2 = diag(signal(ind).^2);
else
    C2 = 1;
end

% Compute condition number
tmp = (X' * C2 * X);
cond = rcond(tmp);
    
if (cond > 1e-10) % some small number
 
    % perform regression to estimate model parameters m
    m = tmp \ X' * C2 * real(log(signal(ind)));
    
    m(1)    = exp(m(1));
    m(2:7)  = m(2:7)  * 1e-9;   % Convert back to SI units
    m(8:22) = m(8:22) * 1e-18;  % Convert back to SI units
        
else
    warning('rcond fail in dki_lls_1d_data2fit')
    m = zeros(1, 22);
end
