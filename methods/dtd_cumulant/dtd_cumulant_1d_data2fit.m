function m = dtd_cumulant_1d_data2fit(signal, xps, opt, ind)
% function m = dtd_cumulant_1d_data2fit(signal, xps, opt, ind)
%
% Diffusion tensor distribution (DTD) modeling using cumulant expansion:
% This function calculates the first two terms of the cumulant expansion 
% from Q-space trajectory (QTI) data. 
%
% In the cumulant expansion
% - The first term corresponds to the mean of the tensor distribution, a second order
%   tensor, which is closely realted to the diffusion tensor in DTI
% - The second term is the cumulant of the tensor distribution, a fourth order tensor
% - The third term is a sixth order tensor
%
% The output from this function will be a model parameter vector of
% dimension 1 + 6 + 21 + 56 = 84
%

if (nargin < 4), ind = ones(size(signal)) > 0; end

% log S = X * B (B --> m, our model parameters)
%
% Correct for heteroscedasticity
%
% C * log S = C * X * B
%
% inv(X' * C' * C * X) * X' * C' * C * log S = B
%
% Compute this whole step for each iteration. It is slow, but use the
% parallell toolbox if you are in a hurry

if 0
    % Setup regressors for DTI model
    X  = [ones(sum(ind), 1) -xps.bt(ind,:) * 1e-9];
end

% Setup regressors for diffusion tensor distribution (DTD) model
b0 = ones(size(xps.bt(ind,:),1), 1);
b2 = xps.bt(ind,:)      * 1e-9 ;   %SI unit conversion
b4 = tm_1x6_to_1x21(b2);           %SI unit conversion already done for b2
b6 = tm_1x6_to_1x56(b2);           %SI unit conversion already done for b2
X = [b0 b2 b4 b6];

%b_trace = tm_inner(bt, [1 1 1 0 0 0]);
    
if (opt.dtd_cumulant.do_heteroscedasticity_correction)
    C2 = diag(signal(ind));
else
    C2 = 1;
end

tmp = (X' * C2 * X);

if (rcond(tmp) > 1e-10) % some small number
    %disp('rcond ok')
 
    % perform regression to estimate model parameters m
    m = tmp \ X' * C2 * real(log(signal(ind)));
    
    m(1)     = exp(m(1));
    m(2:7)   = m(2:7)   * 1e-9;   %converting back to SI units
    m(8:28)  = m(8:28)  * 1e-18;  %converting back to SI units
    m(29:84) = m(29:84) * 1e-27;  %converting back to SI units   %OK?
    
else
    warning('rcond fail in dtd_cumulant_1d_data2fit')
    % number of paramters, S0 + 6 for mean + 21 for cov = 28
    m = zeros(1,84);
end

