function opt = dtd_covariance_opt(opt)
% function opt = dtd_covariance_opt(opt)
%
% Makes sure that all needed fields in the options structure are present

opt.dtd_covariance.present = 1;

x = 'dtd_covariance'; % for shortening 

opt.(x) = msf_ensure_field(opt.(x), 'do_heteroscedasticity_correction', 1);
opt.(x) = msf_ensure_field(opt.(x), 'do_regularization', 0);
opt.(x) = msf_ensure_field(opt.(x), 'do_clamping', 1);
opt.(x) = msf_ensure_field(opt.(x), 'do_extra_fit', 0);
opt.(x) = msf_ensure_field(opt.(x), 'do_post_fit_masking', 0);
opt.(x) = msf_ensure_field(opt.(x), 'allow_subspace_estimation', 1);

opt.(x) = msf_ensure_field(opt.(x), 'cond_limit', 1e-10);
opt.(x) = msf_ensure_field(opt.(x), 'rank_limit', 1e-3);


% Enable the use of the 1d_data2fit for diffusional kurtosis imaging (DKI)
opt.(x) = msf_ensure_field(opt.(x), 'do_dki', 0);

% control which maps that are generated as nifti files
opt.(x) = msf_ensure_field(opt.(x), 'fig_maps', ...
    {'s0','MD', 'ad', 'rd', 'FA', 'uFA', 'MKi', 'MKa', 'MKt', 'C_MD', 'C_c', 'C_mu', 'C_M'});

opt.(x) = msf_ensure_field(opt.(x), 'fig_prefix', 'dtd_covariance');

% produce standard fa-color map
opt.(x) = msf_ensure_field(opt.(x), 'fig_cmaps',{'FA'});
opt.(x) = msf_ensure_field(opt.(x), 'fig_ccol', {'u'});
opt.(x) = msf_ensure_field(opt.(x), 'fig_ccolnorm',{'mask'});


