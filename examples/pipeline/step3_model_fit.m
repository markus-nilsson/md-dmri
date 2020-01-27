% Fit models to the data

% Connect to data
ps = step0_define_paths();

% Set options
opt = mdm_opt;
opt.do_overwrite = 1;
opt.verbose      = 1;

% Connect to data
s = mdm_s_from_nii(fullfile(ps.op, 'FWF_mc.nii.gz'));

% Smooth the data a bit
opt.filter_sigma = 0.6;

% Do covariance analysis using all of the data
dtd_covariance_pipe(s, ps.op, opt);

% Do DTI, using only lower b values and linear tensor data
i_dti = s.xps.b_delta > 0.99 & s.xps.b < 1.1e9;
s_dti = mdm_s_subsample(s, i_dti);
dti_lls_pipe(s_dti, ps.op, opt);

% Do DKI, using only linear tensor data
i_dki = s.xps.b_delta > 0.99;
s_dki = mdm_s_subsample(s, i_dki);
dki_lls_pipe(s_dki, ps.op, opt);

% View the data
% mgui
