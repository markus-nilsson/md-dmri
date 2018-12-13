function opt = ivim_opt(opt)
% function opt = ivim_opt(opt)
%
% Makes sure that all needed fields in the options structure are present

opt.ivim.present = 1;

opt.ivim = msf_ensure_field(opt.ivim, 'lsq_opts', ...
    optimoptions('lsqcurvefit', 'display', 'off','MaxFunEvals',1e4));

opt.ivim = msf_ensure_field(opt.ivim, 'pa_method', 1); 

opt.ivim = msf_ensure_field(opt.ivim, 'fig_maps', ...
    {'s0', 'f_blood', 'D_blood', 'D_tissue'});

opt.ivim = msf_ensure_field(opt.ivim, 'fig_prefix', 'ivim');

opt.ivim = msf_ensure_field(opt.ivim, 'n_rep', 3);
