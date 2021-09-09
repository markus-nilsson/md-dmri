function opt = mdm_mrtrix_opt(opt)
% function opt = mdm_mrtrix_opt(opt)

if (nargin < 1), opt = []; end

opt = mdm_opt(opt);


%% DWIDENOISE
% https://mrtrix.readthedocs.io/en/latest/reference/commands/dwidenoise.html

opt.mdm.mrtrix.dwidenoise.present = 1;

opt.mdm.mrtrix.dwidenoise = msf_ensure_field(opt.mdm.mrtrix.dwidenoise, 'do_noise', 0); % Estmate noise map
opt.mdm.mrtrix.dwidenoise = msf_ensure_field(opt.mdm.mrtrix.dwidenoise, 'do_mask', 0); % Use mask to limit processing to mask > 0 region
opt.mdm.mrtrix.dwidenoise = msf_ensure_field(opt.mdm.mrtrix.dwidenoise, 'window', 0); % 0 means automatic window size. Alternativelt, state integer array, e.g. [5 5 5].

%% MRDEGIBBS
% https://mrtrix.readthedocs.io/en/latest/reference/commands/mrdegibbs.html

opt.mdm.mrtrix.mrdegibbs.present = 1;


%% DWI2MASK
% https://mrtrix.readthedocs.io/en/latest/reference/commands/dwi2mask.html

opt.mdm.mrtrix.dwi2mask.present = 1;

