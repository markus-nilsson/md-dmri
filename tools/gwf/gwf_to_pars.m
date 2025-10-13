function xps = gwf_to_pars(gwf, rf, dt, opt)
% function xps = gwf_to_pars(gwf, rf, dt)
%
% gwf - gradient waveform of size N x 3
% rf  - effect of rf pulses (range -1 to 1), size N x 1
% dt  - time step of waveform
% opt - options structure

if (nargin < 4), opt = []; end, opt = gwf_opt(opt);

if (iscell(gwf))
    xps = cell(numel(gwf));
    for c = 1:numel(gwf)
        xps{c} = gwf_to_pars(gwf{c}, rf, dt);
    end
    xps = mdm_xps_merge(xps);
    xps = rmfield(xps, 's_ind');
    return;
end


% b-tensor and associated metrics
xps = mdm_xps_from_bt(gwf_to_bt(gwf, rf, dt, opt));

% Max gradient amplitude and slew rate 
xps.slew_rate_max     = max(abs(diff(gwf, 1, 1)),[],1) / dt;
xps.gradient_max      = max(abs(gwf),[],1);
xps.gradient_max_norm = max(abs( sqrt(sum(gwf.^2, 2))));

% Spectral properties
[M0,M1] = gwf_to_spectral_moments(gwf, rf, dt);
M1_pars = tm_3x3_to_tpars(M1);
xps.gwf_spectral_M0       = tm_3x3_to_1x6(M0);
xps.gwf_spectral_M1       = tm_3x3_to_1x6(M1);
xps.gwf_spectral_M1_iso   = M1_pars.iso;
xps.gwf_spectral_M1_delta = M1_pars.delta;

% Approximately V_omega^1/2 in Nilsson et al (2017) NMR Biomed
xps.gwf_spectral_trace_rms_norm = ...
    sqrt(xps.gwf_spectral_M1_iso / xps.b);


% Maxwell index: This is a relative index
xps.maxwell_index = gwf_maxwell_index(gwf, rf, dt); % unit: (T/m)^2 s

% Energy index
xps.energy_index = sum(gwf.^2,1) * dt;


% Gradient moments
[g_eff, t] = gwf_to_g_eff(gwf, rf, dt);
r = @(rf,n) repmat(rf, 1, n);

xps.k0 = msf_const_gamma(opt.gwf.nucleus) * sum( g_eff .* r(t.^0,3), 1 ) * dt;
xps.k1 = msf_const_gamma(opt.gwf.nucleus) * sum( g_eff .* r(t.^1,3), 1 ) * dt;
xps.k2 = msf_const_gamma(opt.gwf.nucleus) * sum( g_eff .* r(t.^2,3), 1 ) * dt;

xps.alpha_norm = (sum(xps.k1.^2));



