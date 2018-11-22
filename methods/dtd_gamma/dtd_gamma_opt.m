function opt = dtd_gamma_opt(opt)
% function opt = dtd_gamma_opt(opt)
%
% Makes sure that all needed fields in the options structure are present

opt.dtd_gamma.present = 1;

opt.dtd_gamma = msf_ensure_field(opt.dtd_gamma, 'tmp', 1); 
opt.dtd_gamma = msf_ensure_field(opt.dtd_gamma, 'pa_method', 1); 
opt.dtd_gamma = msf_ensure_field(opt.dtd_gamma, 'lsq_opts', ...
    optimoptions('lsqcurvefit', 'display', 'off','MaxFunEvals',1e3));
opt.dtd_gamma = msf_ensure_field(opt.dtd_gamma, 'do_plot', 0);
opt.dtd_gamma = msf_ensure_field(opt.dtd_gamma, 'do_weight', 0);
opt.dtd_gamma = msf_ensure_field(opt.dtd_gamma, 'do_pa_weight', 1);
opt.dtd_gamma = msf_ensure_field(opt.dtd_gamma, 'weight_sthresh', .07);
opt.dtd_gamma = msf_ensure_field(opt.dtd_gamma, 'weight_wthresh', 2);
opt.dtd_gamma = msf_ensure_field(opt.dtd_gamma, 'weight_mdthresh', 1e-9);
opt.dtd_gamma = msf_ensure_field(opt.dtd_gamma, 'fig_maps', ...
    {'s0','iso','mu2iso','mu2aniso','ufa','ciso','cmu','s0', ...
    'MD', 'Vi', 'Va', 'Vt', 'MKi', 'MKa', 'MKt', 'ufa'});
opt.dtd_gamma = msf_ensure_field(opt.dtd_gamma, 'fig_prefix', 'dtd_gamma');

% Number of identical fitting repetitions (keeping smallest residual)
% Very expensive
opt.dtd_gamma = msf_ensure_field(opt.dtd_gamma, 'fit_iters', 1);

% Number of random guesses to start from (keeping guess with smallest residual)
% Not expensive
opt.dtd_gamma = msf_ensure_field(opt.dtd_gamma, 'guess_iters', 50);

% Decide if multiple series should be assumed to have different baseline
% signal (s_ind has multiple unique values).
opt.dtd_gamma = msf_ensure_field(opt.dtd_gamma, 'do_multiple_s0', 1);

% Bounds for initial guess and fitting (not including relative signal for
% multiple series. This is done in the data2fit function.
% Note that the first value is S(b=0)/max(signal), i.e., a relative signal.
opt.dtd_gamma = msf_ensure_field(opt.dtd_gamma, 'fit_lb', [  0 1e-12 [1 1]*1e-24 ]);
opt.dtd_gamma = msf_ensure_field(opt.dtd_gamma, 'fit_ub', [ 10 4e-9  [1 1]*5e-18 ]);

% used in dtd_gamma_pipe.m
opt.dtd_gamma = msf_ensure_field(opt.dtd_gamma, 'do_pa', 1);

% used in mdm_fit.m (work needed here to streamline things)
opt.dtd_gamma = msf_ensure_field(opt.dtd_gamma, 'pa_method', 1);
