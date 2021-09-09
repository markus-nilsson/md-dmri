function opt = ning18_opt(opt)
% function opt = ning18_opt(opt)
%
% Makes sure that all needed fields in the options structure are present

opt.ning18.present = 1;

opt.ning18 = msf_ensure_field(opt.ning18, ...
    'do_heteroscedasticity_correction', 1);

% control which maps that are generated as nifti files
opt.ning18 = msf_ensure_field(opt.ning18, 'fig_maps', ...
    {'s0', 'MD', 'V', 'Vk', ...
    'MK', ...
    'k', 'tau', 'MKk', ...
    'msr'});

opt.ning18 = msf_ensure_field(opt.ning18, 'fig_prefix', 'ning18');

opt.ning18 = msf_ensure_field(opt.ning18, 'pa_method', 1);

% produce standard fa-color map
opt.ning18 = msf_ensure_field(opt.ning18, 'fig_cmaps',{});
opt.ning18 = msf_ensure_field(opt.ning18, 'fig_ccol', {});
opt.ning18 = msf_ensure_field(opt.ning18, 'fig_ccolnorm',{});


