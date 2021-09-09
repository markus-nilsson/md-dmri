% Run motion correction on the data

% Connect to data
ps = step0_define_paths();

% Set options
opt = mdm_opt;
opt.do_overwrite = 1;
opt.verbose      = 1;

% Connect to data
s = mdm_s_from_nii(fullfile(ps.op, 'FWF.nii.gz'));

% Motion correction
p_fn = elastix_p_write(elastix_p_affine(200), fullfile(ps.op, 'p.txt'));
s_mc = mdm_s_mec(s, p_fn, ps.op, opt);

% Just for fun: Make a powder averaged image too
s_mc.xps = rmfield(s_mc.xps, 's_ind');
s_mc_pa = mdm_s_powder_average(s_mc, ps.op, opt);