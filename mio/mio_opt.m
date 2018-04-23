function opt = mio_opt(opt)
% function opt = mio_opt(opt)

if (nargin < 1), opt = []; end

opt = mdm_opt(opt);

opt.mio.present = 1;

opt.mio = msf_ensure_field(opt.mio, 'no_parfor', 0); 

opt.mio.coreg.present = 1;
opt.mio.coreg = msf_ensure_field(opt.mio.coreg, 'clear_header', 1);
opt.mio.coreg = msf_ensure_field(opt.mio.coreg, 'assume_las', 1);
opt.mio.coreg = msf_ensure_field(opt.mio.coreg, 'pad_xyz', [0 0 0]);
opt.mio.coreg = msf_ensure_field(opt.mio.coreg, 'adjust_intensity', 0);



opt.mask.present = 1;
opt.mask = msf_ensure_field(opt.mask, 'pca_threshold', 1.3);


opt.mask = msf_ensure_field(opt.mask, 'b0_ind', 1);
opt.mask = msf_ensure_field(opt.mask, 'threshold', 0.1);


opt.mio.pa.present = 1;
opt.mio.pa = msf_ensure_field(opt.mio.pa, 'do_abs', 1);
opt.mio.pa = msf_ensure_field(opt.mio.pa, 'method', 'ari');


opt.mio.ref_extrapolate.present = 1;
opt.mio.ref_extrapolate = msf_ensure_field(opt.mio.ref_extrapolate, 'do_subspace_fit', 0);

