function opt = mdm_opt(opt)
% function opt = mdm_opt(opt)
%
% Specifies default options 

% opt.nii_ext - eiterh '.nii' or '.nii.gz' for compressed nii

if (nargin < 1), opt.present = 1; end

opt = msf_ensure_field(opt, 'nii_ext', '.nii.gz');
opt = msf_ensure_field(opt, 'do_overwrite', 1);
opt = msf_ensure_field(opt, 'verbose', 0);
opt = msf_ensure_field(opt, 'assert_input_args', 1);

opt = msf_ensure_field(opt, 'do_recon', 1);
opt = msf_ensure_field(opt, 'do_xps2pdf', 0);

opt = msf_ensure_field(opt, 'xps_merge_clear_s_ind', 0);

opt = msf_ensure_field(opt, 'xps_merge_rethrow_error', 1);
opt = msf_ensure_field(opt, 'pa_rethrow_error', 1);


opt = msf_ensure_field(opt, 'mdm_xps_throw_error', 1);
opt = msf_ensure_field(opt, 'mdm_nii_rescale', 1);


opt = msf_ensure_field(opt, 'filter_sigma', 0);


opt = msf_ensure_field(opt, 'do_mask', 1);
opt = msf_ensure_field(opt, 'do_data2fit', 1);
opt = msf_ensure_field(opt, 'do_fit2param', 1);
opt = msf_ensure_field(opt, 'do_param2nii', 1);


opt = msf_ensure_field(opt, 'do_nii2pdf', 1);
opt = msf_ensure_field(opt, 'do_dtdpdf', 1);


opt.mdm.present = 1;
opt.mdm = msf_ensure_field(opt.mdm, 'mask_suffix', 'mask');
opt.mdm = msf_ensure_field(opt.mdm, 'pa_suffix', 'pa');
opt.mdm = msf_ensure_field(opt.mdm, 'txt_read_skip_comments', 0);

% motion correction
opt.mdm.mec.present = 1;

% this needs to be validated for every data set
opt.mdm.mec = msf_ensure_field(opt.mdm.mec, 'do_rotate_bvec', 0);

% extrapolation-based motion correction
opt.mdm.mec_eb.present = 1;
opt.mdm.mec_eb = msf_ensure_field(opt.mdm.mec_eb, 'b_limit', 1.1e9);


opt.mask.present = 1;

% extra layer of granularity, both opt.do_overwrite and
% opt.mask.do_overwrite must be true in order for mask overwrite to take
% place
opt.mask = msf_ensure_field(opt.mask, 'do_overwrite', 0);


% options for powder averaging
opt.mdm.pa.present = 1;
opt.mdm.pa = msf_ensure_field(opt.mdm.pa, 'db', 0.1e9);
opt.mdm.pa = msf_ensure_field(opt.mdm.pa, 'db_delta2', 0.25);



