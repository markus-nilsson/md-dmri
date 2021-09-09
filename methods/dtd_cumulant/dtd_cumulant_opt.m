function opt = dtd_cumulant_opt(opt)
% function opt = dtd_cumulant_opt(opt)
%
% Makes sure that all needed fields in the options structure are present

opt.dtd_cumulant.present = 1;

opt.dtd_cumulant = msf_ensure_field(opt.dtd_cumulant, ...
    'do_heteroscedasticity_correction', 1);

% control which maps that are generated as nifti files
opt.dtd_cumulant = msf_ensure_field(opt.dtd_cumulant, 'fig_maps', ...
    {'s0','FA','C_MD', 'C_c', 'C_mu'});

opt.dtd_cumulant = msf_ensure_field(opt.dtd_cumulant, 'fig_prefix', 'dtd_cumulant');

% produce standard fa-color map
opt.dtd_cumulant = msf_ensure_field(opt.dtd_cumulant, 'fig_cmaps',{'FA'});
opt.dtd_cumulant = msf_ensure_field(opt.dtd_cumulant, 'fig_ccol', {'u'});
opt.dtd_cumulant = msf_ensure_field(opt.dtd_cumulant, 'fig_ccolnorm',{'mask'});
