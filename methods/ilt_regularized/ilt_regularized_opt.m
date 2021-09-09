function opt = ilt_regularized_opt(opt)
% function opt = ilt_regularized_opt(opt)
%
% Makes sure that all needed fields in the options structure are present

opt.ilt_regularized.present = 1;

opt.ilt_regularized = msf_ensure_field(opt.ilt_regularized, 'tmp', 1); 
opt.ilt_regularized = msf_ensure_field(opt.ilt_regularized, 'dmin', 1e-11);
opt.ilt_regularized = msf_ensure_field(opt.ilt_regularized, 'dmax', 5e-9);
opt.ilt_regularized = msf_ensure_field(opt.ilt_regularized, 'sample_number_D', 50); 
opt.ilt_regularized = msf_ensure_field(opt.ilt_regularized, 'smooth_mode', 4); 
opt.ilt_regularized = msf_ensure_field(opt.ilt_regularized, 'lsq_opts', ...
    optimoptions('lsqcurvefit', 'display', 'off','MaxFunEvals',1e3));
opt.ilt_regularized = msf_ensure_field(opt.ilt_regularized, 'do_plot', 0);
opt.ilt_regularized = msf_ensure_field(opt.ilt_regularized, 'do_pa', 1);
opt.ilt_regularized = msf_ensure_field(opt.ilt_regularized, 'fig_prefix', 'ilt_regularized');
