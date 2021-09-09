% GOAL: to fit the diffusion tensor distribution model (DTD) model to the data.
% The estimated parameters are the the mean and covarance of the DTD

% Should this toplevel script call the dti_cumulant_pipe function instead of bypassing it?
% suggestions: expand pipe to pipeline, and expand opt to options, so it is
% not confused with optimization.

% Define paths do read and save data
inputpath  = 'NII_merge';
inputpath  = '/Users/westin/Dropbox/Work/Share/westin-nilsson/2016/Connectome_example/NII_merge';
outputpath = [inputpath '/tempCumulant'];

% Connect with the motion corrected data
clear s;
s.nii_fn = fullfile(inputpath, 'bt_data_mc.nii'); 
s.xps    = mdm_xps_load(fullfile(inputpath, 'bt_data_xps.mat'));

% fix an issue that some high b-values were incorrectly labelled 
% as 2.45 not 2.5
s.xps.b(s.xps.b > 2.4e9) = 2.5e9;

% Smooth the data
s = mdm_smooth(s, 0.6, outputpath);

% Set output filenames
mfs_fn = fullfile(outputpath, 'mfs.mat'); % model fit structure file name
dps_fn = fullfile(outputpath, 'dps.mat'); % derived parameter structure file name

% make it parallel
if (isempty(gcp)), parpool(4); end

% mask the data
opt.mask.thresh = 0.06;
opt.mask.b0_ind = s.xps.b < 0.2e9;
s = mdm_mask(s, @mio_mask_thresh, outputpath, opt);

% Define fit options
opt = dtd_cumulant_opt;
opt.k_range = 15; % limit to one slice for now
%opt.dtd_cumulant.do_heteroscedasticity_correction = 0; % default is 1

% Perform paramter fit
dtd_cumulant_4d_data2fit(s, mfs_fn, opt);
dtd_cumulant_4d_fit2param(mfs_fn, dps_fn, opt); 

% Save nifti parameter maps
mdm_param2nii(dps_fn, outputpath, opt.dtd_cumulant, opt);

% inspect results using 'mgui'
mgui







