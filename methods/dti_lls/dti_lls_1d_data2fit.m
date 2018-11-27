function m = dti_lls_1d_data2fit(signal, xps, opt, ind)
% function m = dti_lls_1d_data2fit(signal, xps, opt, ind)

if (nargin < 4), ind = ones(size(signal)) > 0; end

if (xps.n ~= numel(signal))
    error('The xps does not match the data: xps.n = %i vs numel(signal) = %i', ...
        xps.n, numel(signal));
end

% log S = X * B (B --> m, our model parameters)
%
% Correct for heteroscedasticity
%
% C * log S = C * X * B
%
% inv(X' * C' * C * X) * X' * C' * C * log S = B
%
% Compute this whole step for each iteration. It is slow, but we're not in
% a hurry with DTI any longer
X  = [ones(sum(ind), 1) -xps.bt(ind,:) * 1e-9];

if (opt.dti_lls.do_heteroscedasticity_correction)
    C2 = diag(signal(ind).^2);
else
    C2 = 1;
end

tmp = (X' * C2 * X);

if (rcond(tmp) > 1e-10) % some small number
    
    m = tmp \ X' * C2 * real(log(signal(ind)));
    
    m(1) = exp(m(1));
    m(2:7) = m(2:7) * 1e-9;
    
else
    m = zeros(1,7);
end


end