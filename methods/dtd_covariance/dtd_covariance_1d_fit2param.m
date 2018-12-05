function dps = dtd_covariance_1d_fit2param(m, f, opt)
% function dps = dtd_covariance_1d_fit2param(m, f, opt)
%
% m - model fit parameters of size Nx28
% f - reshape function, if desired output is IxJxK (=N)
% opt - options
%
% display parameters will be in non-SI units (e.g. um2/ms for MD)

if (nargin < 2) || (isempty(f)), f = @(x,n) x; end
if (nargin < 3), opt = []; end

opt = dtd_covariance_opt(opt);

if (opt.dtd_covariance.do_regularization)
    reg_dt = 0.1;
    reg_ct = 0.1;
else
    reg_dt = 0.0001;
    reg_ct = 0.0001;
end

% compute display parameters in um2/ms format
dps.s0 = f(m(:,1), []);
dps = tm_dt_to_dps(m(:,2:7) * 1e9, dps, f, reg_dt);
dps = tm_ct_to_dps(m(:,8:28) * 1e18, dps, f, reg_ct);

% clamp measures to avoid extreme values to take precedence in averages
if (opt.dtd_covariance.do_clamping)
    
    % clamp DTI measures
    dps.MD    = mio_min_max_cut(dps.MD, -10, 10);
    dps.FA    = mio_min_max_cut(dps.FA, -1, 2);
    dps.ad    = mio_min_max_cut(dps.ad, -10, 10);
    dps.rd    = mio_min_max_cut(dps.rd, -10, 10);
    
    % clamp C_x measures
    dps.C_mu  = mio_min_max_cut(dps.C_mu, -1, 2);
    dps.C_M   = mio_min_max_cut(dps.C_M, -1, 2);
    dps.C_c   = mio_min_max_cut(dps.C_c, -1, 2);
    
    % clamp kurtosis measures
    dps.MKi  = mio_min_max_cut(dps.MKi, -1.0, 4.0);
    dps.MKa  = mio_min_max_cut(dps.MKa, -1.0, 4.0);
    dps.MKt  = mio_min_max_cut(dps.MKt, -1.0, 4.0);
    dps.MK   = mio_min_max_cut(dps.MK,  0.0, 4.0);
    dps.MKad = mio_min_max_cut(dps.MKad, 0.0, 4.0);
    dps.MKd  = mio_min_max_cut(dps.MKd, 0.0, 4.0);
    
end
