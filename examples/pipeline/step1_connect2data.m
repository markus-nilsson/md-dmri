% This is the first step of a processing pipeline, written by Jan Brabec
%
% Before you begin, follow the instructions in step0_define_paths to 
% download the data and set the paths according to your preferences

% Connect to data
ps = step0_define_paths();

% Set options
opt = mdm_opt;
opt.do_overwrite = 1;
opt.verbose      = 1;

b_delta_lte = 1;
b_delta_ste = 0;

% Load linear and spherical data
f = @(nii_fn, b_delta) mdm_s_from_nii(fullfile(ps.ip, nii_fn), b_delta);

s = {...
    f('BRAIN [DIB2019]_FWF_DIG_STE_nx1_10.nii.gz', b_delta_ste), ...
    f('BRAIN [DIB2019]_FWF_DIG_LTE_pt1_11.nii.gz', b_delta_lte), ...
    f('BRAIN [DIB2019]_FWF_DIG_STE_nx2_13.nii.gz', b_delta_ste), ...
    f('BRAIN [DIB2019]_FWF_DIG_LTE_pt2_14.nii.gz', b_delta_lte), ...
    f('BRAIN [DIB2019]_FWF_DIG_STE_nx3_16.nii.gz', b_delta_ste), ...
    f('BRAIN [DIB2019]_FWF_DIG_LTE_pt3_17.nii.gz', b_delta_lte), ...
    f('BRAIN [DIB2019]_FWF_DIG_STE_nx4_19.nii.gz', b_delta_ste), ...
    f('BRAIN [DIB2019]_FWF_DIG_LTE_pt4_20.nii.gz', b_delta_lte), ...
    f('BRAIN [DIB2019]_FWF_DIG_STE_nx5_22.nii.gz', b_delta_ste)};

% Merge into one file
s = mdm_s_merge(s, ps.op, 'FWF', opt);

% Also make a powder-averaged data set for visualization
s.xps = rmfield(s.xps, 's_ind');
s_pa = mdm_s_powder_average(s, ps.op, opt);

% View the merged and powder averaged data
mgui