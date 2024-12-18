function fn = dtd_covariance_pa_pipe(s, paths, opt)
% function fn = dtd_covariance_pa_pipe(s, paths, opt)
%
% Map the isotropic covariances using the second order cumulant model, 
% on powder averaged data
%
% s     - input structure
% paths - either a pathname or a path structure (see mdm_paths)
% opt   - (optional) options that drive the pipeline
%         opt.mask.thresh = 0.1, you may want to adjust it 
%            
% fn    - a cell arary with filenames to generated nii files

if (nargin < 2), paths = fileparts(s.nii_fn); end
if (nargin < 3), opt.present = 1; end

% Init structures
opt   = mdm_opt(opt);

% control which maps that are generated as nifti files
maps = {'s0','C_MD', 'C_mu', 'MD', 'MKt', 'MKa', 'MKi'};
opt.dtd_covariance.present = 1;
opt.dtd_covariance = msf_ensure_field(opt.dtd_covariance, 'fig_maps', maps);   
opt.dtd_covariance = msf_ensure_field(opt.dtd_covariance, 'fig_cmaps',{});
opt.dtd_covariance.fig_prefix = 'dtd_covariance_pa';
opt = dtd_covariance_opt(opt);
opt.dki_pa.do_heteroscedasticity_correction = 1;

paths = mdm_paths(paths, 'dtd_covariance_pa');   

msf_log(['Starting ' mfilename], opt);

% Smooth and prepare mask
if (opt.filter_sigma > 0)
    s = mdm_s_smooth(s, opt.filter_sigma, paths.nii_path, opt);
end

s = mdm_s_mask(s, @mio_mask_threshold, paths.nii_path, opt);

% Fit and derive parameters
opt.dki_pa.do_include_b_tensor_anisotropy = 1;
mdm_data2fit(@dki_pa_4d_data2fit, s, paths.mfs_fn, opt);
mdm_fit2param(@dtd_covariance_4d_fit2param, paths.mfs_fn, paths.dps_fn, opt);

% Save niftis
fn = mdm_param2nii(paths.dps_fn, paths.nii_path, opt.dtd_covariance, opt); 

