function opt = dtd_covariance_opt(opt)
% function opt = dtd_covariance_opt(opt)
%
% Makes sure that all needed fields in the options structure are present

opt.dtd_covariance.present = 1;

opt.dtd_covariance = msf_ensure_field(opt.dtd_covariance, ...
    'do_heteroscedasticity_correction', 1);

opt.dtd_covariance = msf_ensure_field(opt.dtd_covariance, ...
    'allow_subspace_estimation', 1);

% Enable the use of the 1d_data2fot for diffusional kurtosis imaging (DKI)
opt.dtd_covariance = msf_ensure_field(opt.dtd_covariance, ...
    'do_dki', 0);

% control which maps that are generated as nifti files
opt.dtd_covariance = msf_ensure_field(opt.dtd_covariance, 'fig_maps', ...
    {'s0','FA','C_MD', 'C_c', 'C_mu'});

opt.dtd_covariance = msf_ensure_field(opt.dtd_covariance, 'fig_prefix', 'dtd_covariance');

% produce standard fa-color map
opt.dtd_covariance = msf_ensure_field(opt.dtd_covariance, 'fig_cmaps',{'FA'});
opt.dtd_covariance = msf_ensure_field(opt.dtd_covariance, 'fig_ccol', {'u'});
opt.dtd_covariance = msf_ensure_field(opt.dtd_covariance, 'fig_ccolnorm',{'mask'});


