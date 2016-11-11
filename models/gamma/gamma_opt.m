function opt = gamma_opt(opt)
% function opt = gamma_opt(opt)
%
% Makes sure that all needed fields in the options structure are present

opt.gamma.present = 1;

opt.gamma = msf_ensure_field(opt.gamma, 'tmp', 1); 
opt.gamma = msf_ensure_field(opt.gamma, 'lsq_opts', ...
    optimoptions('lsqcurvefit', 'display', 'off','MaxFunEvals',500));
opt.gamma = msf_ensure_field(opt.gamma, 'do_plot', 0);
opt.gamma = msf_ensure_field(opt.gamma, 'do_pa', 0);
opt.gamma = msf_ensure_field(opt.gamma, 'do_weight', 0);
opt.gamma = msf_ensure_field(opt.gamma, 'do_pa_weight', 1);
opt.gamma = msf_ensure_field(opt.gamma, 'weight_sthresh', .05);
opt.gamma = msf_ensure_field(opt.gamma, 'weight_wthresh', 2);
opt.gamma = msf_ensure_field(opt.gamma, 'weight_mdthresh', 1e-9);
opt.gamma = msf_ensure_field(opt.gamma, 'fig_maps', ...
    {'s0', 'MD', 'MKi', 'MKa', 'MKt', 'ufa'}); 
opt.gamma = msf_ensure_field(opt.gamma, 'fig_prefix', 'gamma');
opt.gamma = msf_ensure_field(opt.gamma, 'fit_iters', 1);
opt.gamma = msf_ensure_field(opt.gamma, 'do_random_guess', 0);
