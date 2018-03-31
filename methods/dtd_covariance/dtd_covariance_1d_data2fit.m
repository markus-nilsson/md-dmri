function [m,cond,n_rank] = dtd_covariance_1d_data2fit(signal, xps, opt, ind)
% function [m,cond,n_rank] = dtd_covariance_1d_data2fit(signal, xps, opt, ind)
%
% Diffusion tensor distribution (DTD) modeling using cumulant expansion:
% This function calculates the first two terms of the cumulant expansion 
% from Q-space trajectory (QTI) data. 
%
% In the cumulant expansion
% - The first term corresponds to the mean of the tensor distribution, a second order
%   tensor, which is closely realted to the diffusion tensor in DTI
% - The second term is the covariance of the tensor distribution, a fourth order tensor
%
% The output from this function will be a model parameter vector of
% dimension 1 + 6 + 21 = 28
%
% The second output is the condition number of the matrix used in the
% inversion

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

% Exclude data points with zero or negative values
ind = ind & (signal > 0);

% Setup regressors for diffusion tensor distribution (DTD) model
b0 = ones(xps.n, 1);
b0 = b0(ind);
b2 = xps.bt(ind,:)      * 1e-9 ;   %SI unit conversion
b4 = tm_1x6_to_1x21(b2);


% Check the size of the subspace -- and adjust it to enable estimation 
% with insufficiently well sampled data
n_rank = rank(b4' * b4);

if (n_rank < 21) && (opt.dtd_covariance.allow_subspace_estimation)
    
    % Fit e.g. 16 parameters, in LTE+STE acquisitions
    b4_tmp = b4;
    b4_tmp(:, 4:6) = b4_tmp(:, 4:6) * 1e-1;  % critical for upscaling
    [b4_eig_vec, b4_eigval] = eigs(b4_tmp' * b4_tmp, 21);

    %ind_tmp = diag(abs(b4_eigval)) > 1e-8;
    ind_tmp = (1:21) <= n_rank;

    subspace_coord = b4_eig_vec(:,ind_tmp);

elseif (n_rank == 21)

    % Fit all parameters
    subspace_coord = eye(21);

else
    error('Not enough data to do estimation');
end

% Setup regressors, potentially allow estimation in a subspace
X = [b0 -b2 1/2 * b4 * subspace_coord];
    
if (opt.dtd_covariance.do_heteroscedasticity_correction)
    C2 = diag(signal(ind));
else
    C2 = 1;
end

% Compute condition number, it must be larger than some small number...
tmp = (X' * C2 * X);
cond = rcond(tmp);

if (cond > 1e-10) 
 
    % perform regression to estimate model parameters m
    m = tmp \ X' * C2 * real(log(signal(ind)));
    
    m(1)     = exp(m(1));
    m(2:7)   = m(2:7)  * 1e-9;    % Convert back to SI units
    m(8:end) = m(8:end) * 1e-18;  % Convert back to SI units
    
    m(8 + (0:20)) = subspace_coord * m(8:end);
        
else
    warning('rcond fail in dtd_covariance_1d_data2fit')
    m = zeros(1, 28)';
end
