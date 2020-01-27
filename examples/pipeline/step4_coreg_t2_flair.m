% Coregister T2-FLAIR to dMRI data

% Connect to data
[ps, opt] = step0_define_paths();

% Set options
opt = mdm_opt;
opt.do_overwrite = 1;
opt.verbose      = 1;

% Create a high SNR image with a contrast similar to the T2 FLAIR image
% (high b-values powder averaged image)
s        = mdm_s_from_nii(fullfile(ps.op,'FWF_mc.nii.gz'));
s_pa     = mdm_s_powder_average(s, ps.op, opt);
s_target = mdm_s_subsample(s_pa, 3 == (1:s_pa.xps.n), ps.zp, opt);

% Connect to data
i_t2_nii_fn = fullfile(ps.ip, 'BRAIN [DIB2019]_Axial_T2_FLAIR_2.nii'); % input filename
o_t2_nii_fn = fullfile(ps.op, 'T2_FLAIR.nii.gz'); % output filename

% Do rigid body registration (T2 FLAIR to diffusion)
p      = elastix_p_6dof(150);
p_fn   = elastix_p_write(p, fullfile(ps.ip, 'p_t2_fwf.txt'));
res_fn = elastix_run_elastix(i_t2_nii_fn, s_target.nii_fn, p_fn, ps.zp);

% Save the result
[I,h] = mdm_nii_read(res_fn);
mdm_nii_write(I, o_t2_nii_fn, h);
