function opt = vasco16_opt(opt)
% function opt = vasco16_opt(opt)
%
% Makes sure that all needed fields in the options structure are present

if (nargin < 1), opt = struct; end

opt.vasco16.present = 1;

opt.vasco16 = msf_ensure_field(opt.vasco16, 'tmp', 1);
opt.vasco16 = msf_ensure_field(opt.vasco16, 'lsq_opts', ...
    optimoptions('lsqcurvefit', 'display', 'off'));
opt.vasco16 = msf_ensure_field(opt.vasco16, 'do_plot', 0);

% Fit parameters are specified in model-facing units.
% s0 is relative to max(signal), the physical terms are SI.
opt.vasco16 = msf_ensure_field(opt.vasco16, 'fit_guess', ...
    [1 1e-9 2e-6 0.05 1.0]);
opt.vasco16 = msf_ensure_field(opt.vasco16, 'fit_lb', ...
    [0 0 0 0.00 0.5]);
opt.vasco16 = msf_ensure_field(opt.vasco16, 'fit_ub', ...
    [2 3e-9 25e-6 1.00 1.5]);

% Fixed blood diffusivity in SI units.
opt.vasco16 = msf_ensure_field(opt.vasco16, 'dblood', 1.75e-9);

% Regularization acts on vd in SI units (m/s), while vd2 remains the fitted
% model parameter.
opt.vasco16 = msf_ensure_field(opt.vasco16, 'reg_lambda', 0);
opt.vasco16 = msf_ensure_field(opt.vasco16, 'reg_vd_lb', 0.75e-3);
opt.vasco16 = msf_ensure_field(opt.vasco16, 'reg_vd_ub', 2.75e-3);
opt.vasco16 = msf_ensure_field(opt.vasco16, 'reg_delta_vd', 0.4e-3);
end
