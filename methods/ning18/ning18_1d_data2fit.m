function m = ning18_1d_data2fit(signal, xps, opt, ind)
% function m = ning18_1d_data2fit(signal, xps, opt, ind)
%
% fit the ning18 model to powder averaged data
%
% m(1) = S0
% m(2) = MD
% m(3) = V
% m(4) = V * k
% m(5) = msr

if (nargin < 4), ind = ones(size(signal)) > 0; end

% Exclude data points with zero or negative values
ind = ind & (signal > 0);

% Possibly exclude based on opt-reject
if (isfield(opt.ning18, 'ind_reject'))
    ind = ind & ~opt.ning18.ind_reject;
end

% Correct s0 (just max...) for different sequences to that of the first
if (isfield(xps, 's_ind'))
    s_max = max(signal(xps.s_ind == 1));
    for c_ind = 2:max(xps.s_ind)
        signal(xps.s_ind == c_ind) = signal(xps.s_ind == c_ind) * s_max / max(signal(xps.s_ind == c_ind));
    end
end

% Define effective exchange time
t_ex = ning18_1d_xps2tex(xps);

% Conditioning
b_sc    = 1e-9;
t_ex_sc = 1e2;

% Setup regressors and scale for conditioning
b0  = ones(size(xps.b(ind),1), 1);
b2  = xps.b(ind,:)      * b_sc;
b4  = xps.b(ind,:).^2   * b_sc^2;
b4e = xps.b(ind,:).^2   * b_sc^2    .* t_ex(ind,:) * t_ex_sc;
%
X = [b0     -b2     1/2 * b4    (-1/2) * b4e];

% Correct for heteroscedasticity arising from the log transform, taking
% also the powder-average weights into account if needed (second if
% statement)
if (opt.ning18.do_heteroscedasticity_correction)
    C2 = diag(signal(ind));
else
    C2 = 1;
end
if (isfield(xps, 'pa_w'))
    C2 = C2 .* diag(xps.pa_w(ind));
end

tmp = (X' * C2 * X);

if (rcond(tmp) > 1e-10) % some small number
    
    % perform regression to estimate model parameters m
    m = tmp \ X' * C2 * real(log(signal(ind)));
    
    m(1) = exp(m(1));
    % Scale back to SI units
    m(2) = m(2) * b_sc;
    m(3) = m(3) * b_sc^2;
    m(4) = m(4) * b_sc^2 * t_ex_sc;
    %
    signal_fit  = ning18_1d_fit2data(m, xps);
    m(5)        = mean((signal(ind) - signal_fit(ind)).^2);
else
    warning('rcond fail')
    m = zeros(1, size(X,2)+1);
end