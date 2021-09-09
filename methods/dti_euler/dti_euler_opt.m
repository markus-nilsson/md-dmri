function opt = dti_euler_opt(opt)
% function opt = dti_euler_opt(opt)
%
% Makes sure that all needed fields in the options structure are present

opt.dti_euler.present = 1;

opt.dti_euler = msf_ensure_field(opt.dti_euler, 'tmp', 1); 
opt.dti_euler = msf_ensure_field(opt.dti_euler, 'lsq_opts', ...
    optimoptions('lsqcurvefit', 'display', 'off','MaxFunEvals',1e3));
opt.dti_euler = msf_ensure_field(opt.dti_euler, 'do_plot', 0);
opt.dti_euler = msf_ensure_field(opt.dti_euler, 'ind_start', 1);
opt.dti_euler = msf_ensure_field(opt.dti_euler, 'do_weight', 1);
opt.dti_euler = msf_ensure_field(opt.dti_euler, 'weight_sthresh', .2);
opt.dti_euler = msf_ensure_field(opt.dti_euler, 'weight_wthresh', 2);

% control which maps that are generated as nifti files
opt.dti_euler = msf_ensure_field(opt.dti_euler, 'fig_prefix', 'dti_euler');

opt.dti_euler = msf_ensure_field(opt.dti_euler, 'fig_maps', ...
    {'s0','MD','FA'});

% opt.dti_euler = msf_ensure_field(opt.dti_euler, 'fig_cmaps',    {'FA'});
% opt.dti_euler = msf_ensure_field(opt.dti_euler, 'fig_ccol',     {'t1x6'});
% opt.dti_euler = msf_ensure_field(opt.dti_euler, 'fig_ccolnorm', {'lambda33'});
% 
% opt.dti_euler = msf_ensure_field(opt.dti_euler, 'fig_cmaps',    {'fa',      'cl',         'cp'});
% opt.dti_euler = msf_ensure_field(opt.dti_euler, 'fig_ccol',     {'t1x6',    'lambda33vec','lambda11vec'});
% opt.dti_euler = msf_ensure_field(opt.dti_euler, 'fig_ccolnorm', {'lambda33','mask',       'mask'});

% to produce standard fa-color map, this would be the way:
opt.dti_euler = msf_ensure_field(opt.dti_euler, 'fig_cmaps',{'FA'});
opt.dti_euler = msf_ensure_field(opt.dti_euler, 'fig_ccol',{'u'});
opt.dti_euler = msf_ensure_field(opt.dti_euler, 'fig_ccolnorm',{'mask'});
