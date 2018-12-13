function fn = dki_lls_pipe(s, paths, opt)
% function fn = dki_lls_pipe(s, paths, opt)
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
opt   = dki_lls_opt(opt);

paths = mdm_paths(paths, 'dki_lls');   

msf_log(['Starting ' mfilename], opt);

% Check that the xps is proper
dki_lls_check_xps(s.xps);

% Smooth and prepare mask
s = mdm_s_smooth(s, opt.filter_sigma, paths.nii_path, opt);
s = mdm_s_mask(s, @mio_mask_threshold, paths.nii_path, opt);

% Fit and derive parameters
mdm_data2fit(@dki_lls_4d_data2fit, s, paths.mfs_fn, opt);
mdm_fit2param(@dki_lls_4d_fit2param, paths.mfs_fn, paths.dps_fn, opt);

% Save niftis
fn = mdm_param2nii(paths.dps_fn, paths.nii_path, opt.dki_lls, opt); 

