function opt = color_gamma_opt(opt)
% function opt = color_gamma_opt(opt)
%
% Makes sure that all needed fields in the options structure are present

opt.color_gamma.present = 1;

opt.color_gamma = msf_ensure_field(opt.color_gamma, 'tmp', 1); 
opt.color_gamma = msf_ensure_field(opt.color_gamma, 'lsq_opts', ...
    optimoptions('lsqcurvefit', 'display', 'off','MaxFunEvals',1e3));
opt.color_gamma = msf_ensure_field(opt.color_gamma, 'do_plot', 0);
opt.color_gamma = msf_ensure_field(opt.color_gamma, 'ind_start', 1);
opt.color_gamma = msf_ensure_field(opt.color_gamma, 'do_weight', 1);
opt.color_gamma = msf_ensure_field(opt.color_gamma, 'weight_sthresh', .1);
opt.color_gamma = msf_ensure_field(opt.color_gamma, 'weight_wthresh', 2);

% control which maps that are generated as nifti files
opt.color_gamma = msf_ensure_field(opt.color_gamma, 'fig_maps', ...
    {'s0','iso','fa','cl','cp'});

opt.color_gamma = msf_ensure_field(opt.color_gamma, 'fig_prefix', 'dti');

opt.color_gamma = msf_ensure_field(opt.color_gamma, 'fig_cmaps',    {'fa',      'cl',         'cp'});
opt.color_gamma = msf_ensure_field(opt.color_gamma, 'fig_ccol',     {'t1x6',    'lambda33vec','lambda11vec'});
opt.color_gamma = msf_ensure_field(opt.color_gamma, 'fig_ccolnorm', {'lambda33','mask',       'mask'});

% to produce standard fa-color map, this would be the way:
% opt.color_gamma = msf_ensure_field(opt.color_gamma, 'fig_cmaps',{'fa'});
% opt.color_gamma = msf_ensure_field(opt.color_gamma, 'fig_ccol',{'lambda33vec'});
% opt.color_gamma = msf_ensure_field(opt.color_gamma, 'fig_ccolnorm',{'mask'});
