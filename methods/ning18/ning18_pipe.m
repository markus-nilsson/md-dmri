function fn = ning18_pipe(s, paths, opt)
% function fn = ning18_pipe(s, paths, opt)
%
% s     - input structure
% paths - either a pathname or a path structure (see mdm_paths)
% opt   - (optional) options that drive the pipeline
%            
% fn    - a cell arary with filenames to generated nii files

if (nargin < 2), paths = fileparts(s.nii_fn); end
if (nargin < 3), opt.present = 1; end

% Init structures
opt   = mdm_opt(opt);
opt   = ning18_opt(opt);

paths = mdm_paths(paths, opt.ning18.fig_prefix);   

msf_log(['Starting ' mfilename], opt);

% Check that the xps is proper
ning18_check_xps(s.xps);

opt.mask.do_overwrite = 1;
s = mdm_s_mask(s, @mio_mask_threshold, paths.nii_path, opt);

% Smooth and prepare mask
if (opt.filter_sigma > 0)
    s = mdm_s_smooth(s, opt.filter_sigma, paths.nii_path, opt);
end


% Fit and derive parameters
mdm_data2fit(@ning18_4d_data2fit, s, paths.mfs_fn, opt);
mdm_fit2param(@ning18_4d_fit2param, paths.mfs_fn, paths.dps_fn, opt);

% Save niftis
fn = mdm_param2nii(paths.dps_fn, paths.nii_path, opt.ning18, opt); 

