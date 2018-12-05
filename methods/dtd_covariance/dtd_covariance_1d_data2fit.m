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
%
% For details, see Westin et al (2016) NeuroImage 135

if (nargin < 3), opt = dtd_covariance_opt; end
if (nargin < 4), ind = ones(size(signal)) > 0; end

% log S = X * B (B --> m, our model parameters)
%
% Correct for heteroscedasticity
%
% C * log S = C * X * B
%
% inv(X' * C' * C * X) * X' * C' * C * log S = B
%
% Compute this whole step for each iteration. 

% Exclude data points with zero or negative values
ind = ind & (signal > 0);
signal = signal(ind); 

if (numel(signal) == 0)
    warning('no non-zero signals supplied'); 
    m = zeros(1, 28);
    return;    
end

% Setup regressors for diffusion tensor distribution (DTD) model
b0 = ones(xps.n, 1);
b0 = b0(ind);
b2 = xps.bt(ind,:) * 1e-9 ;   %SI unit conversion
b4 = tm_1x6_to_1x21(b2);

% Setup regressors, potentially allow estimation in a subspace
[subspace_coord,n_rank] = get_subspace_coord(b4, b2, opt);

X = [b0 -b2 1/2 * b4 * subspace_coord];

% Do the heteroscedasticity correction
if (opt.dtd_covariance.do_heteroscedasticity_correction)
    C2 = diag(signal.^2);
else
    C2 = 1;
end

% Compute condition number, it must be larger than some small number...
tmp = (X' * C2 * X);
cond = rcond(tmp);

if (cond < opt.dtd_covariance.cond_limit)
    warning('rcond fail in dtd_covariance_1d_data2fit')
    m = zeros(1, 28);
    return;
end


% perform regression to estimate model parameters m
m = tmp \ X' * C2 * real(log(signal));

% redo with updated C2 and with regularization
if (opt.dtd_covariance.do_regularization)
        
    % add virtual measurements for regularization 
    
    % zeroth cumulant: penalize  s0
    b0_2 = cat(1, b0, ones(1,1));
    b2_2 = cat(1, b2, zeros(1, 6)); 
    b4_2 = cat(1, b4, zeros(1, 21));    
    
    % first cumulant: penalize the whole diffusion tensor + s0
    b0_2 = cat(1, b0_2, zeros(6, 1));
    b2_2 = cat(1, b2_2, eye(6)); % this is the b-tensor
    b4_2 = cat(1, b4_2, zeros(6, 21));
        
    % second cumulant: penalize the covariance tensor
    b0_2 = cat(1, b0_2, zeros(21, 1));
    b2_2 = cat(1, b2_2, zeros(21, 6));    
    b4_2 = cat(1, b4_2, eye(21));
    
    % regression target: desired value of target elements is zero
    rt = cat(1, real(log(signal)), zeros(1+6+21, 1));

    % new regressors
    X2 = [b0_2 -b2_2 1/2 * b4_2 * subspace_coord];
    
    % filter with center 'c' and widht 'w'
    f = @(x,c,w) 1/2 * (tanh( (x-c) / w ) + 1);
    h = @(a,b) sum(a.*b) / sum(b);
    
    n_rep = 2; % redo some times to weigh down data more
    for c_rep = 1:n_rep
        
        % compute signal fit
        s_fit = exp(X * m);
        
        % compute residual variance
        % (xxx: ideally, pull in external noise estimate here)
        res_std = 1/0.8 * mad( sqrt(  (signal - exp(X * m)).^2 ) );
        
        % use min of predicted signal and measured signal, in order to 
        % not start to weigh up points at high b-values where the 
        % model may fail (gross "banana effect")
        s_fit = min(cat(2, s_fit, signal), [], 2);
        
        % penalize the diffusion tensor where the 
        % mean diffusivity is very low (e.g. background)
        if (1)
            %snr = exp(m(1)) / res_std;   
            md = mean(m(2:4));
            
            w_dt = 1e3 * f(-md, -0.1, 0.05);
            w_s0 = 0 * w_dt;
        else
            w_dt = 0;
            w_s0 = 0;
        end
                
        % use average noise to signal for datapoints  bt*dt > 1 as a 
        % regularization weight        
        w_ct = h(res_std ./ s_fit, f(b2 * m(2:7), 1.5, 0.5)).^2;
        w_ct = w_ct * 1e0 + w_dt * 1e1;
        
        % scale regularization weights to current signal levels
        sc = mean(signal.^2);
        w_dt = w_dt * sc;
        w_ct = w_ct * sc * 1e1;
        
        % weigh down the contribution of low signal and extreme misfits
        w_s = f(s_fit ./ min(2*max(signal), exp(m(1))), 0.06, 0.02);
        
        w_s = w_s .* f( - abs(signal - s_fit) / res_std, -5, 1);
        
        % debug
        if (0)
            if (c_rep == 1), clc; end
            md
            snr
            w_dt
            w_ct
            figure(1);
            subplot(2,2,c_rep); cla;
            plot(rt); hold on;
            plot(log(s_fit));
        end
        
        C2_2 = diag(cat(1, w_s .* s_fit.^2, w_s0, w_dt * ones(6,1), w_ct * ones(21, 1)));
        
        tmp = (X2' * C2_2 * X2);
        cond = rcond(tmp);
        
        if (cond < opt.dtd_covariance.cond_limit)
            m = zeros(1, 28);
            return;
        end
        
        m = (tmp) \ X2' * C2_2 * rt;
    end
    

end

m(1)     = exp(m(1));
m(2:7)   = m(2:7)  * 1e-9;    % Convert back to SI units
m(8:end) = m(8:end) * 1e-18;  % Convert back to SI units

m(8 + (0:20)) = subspace_coord * m(8:end);

m = m';


end


function [s, n_rank] = get_subspace_coord(b4, b2, opt)
% function s = get_subspace_coord(b4, opt)
% 
% compute a subspace in which estimation can be done

% use a previously computed value if possible for speedsup
persistent p; 

if ...
        (~isempty(p)) && ...
        numel(p.b4(:)) == numel(b4(:)) && ...
        all(p.b4(:) == b4(:))
    s = p.s; 
    n_rank = p.n_rank;
    return; 
end


% Check the size of the subspace -- and adjust it to enable estimation
% with insufficiently well sampled data (e.g. LTE+STE only)
% Some information will be missing, but MK_I and MK_A can be computed
% anyway
n_rank = rank(b4' * b4 / trace(b2' * b2)^2 * size(b2,1), ...
    opt.dtd_covariance.rank_limit);

if (n_rank < 21) && (opt.dtd_covariance.allow_subspace_estimation)
    
    % Fit e.g. 16 parameters, in LTE+STE acquisitions
    b4_tmp = b4;
    b4_tmp(:, 4:6) = b4_tmp(:, 4:6) * 1e-1;  % critical for upscaling
    [b4_eig_vec, b4_eig_vals] = eigs(b4_tmp' * b4_tmp, 21);
    [b4_eig_vals,ind] = sort(diag(b4_eig_vals),'descend');
    b4_eig_vec = b4_eig_vec(:,ind);
    ind_tmp = (1:21) <= n_rank;
    
    s = b4_eig_vec(:,ind_tmp);
    
elseif (n_rank == 21)
    s = eye(21); % Fit all parameters
else
    error('Not enough data to do estimation');
end

% Store results in the persistent variable (speeds up volume fitting)
p.b4 = b4;
p.s = s;
p.n_rank = n_rank;

end