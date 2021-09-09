function fn = color_gamma_pipe(s, paths, opt)
% function fn = color_gamma_pipe(s, paths, opt)
%
% s     - input structure
% paths - either a pathname or a path structure (see mdm_paths)
% opt   - (optional) options that drive the pipeline
%
% fn    - a cell array with filenames to generated nii files

fn = [];

if (nargin < 2), paths = fileparts(s.nii_fn); end
if (nargin < 3), opt.present = 1; end

% Init structures
opt   = mdm_opt(opt);
opt   = color_gamma_opt(opt);
paths = mdm_paths(paths);     

msf_log(['Starting ' mfilename], opt);    

% Prepare mask
if (opt.do_mask)
    s = mdm_s_mask(s, @mio_mask_threshold, [], opt);
end

% Fit and derive parameters
if (opt.do_data2fit)
    mdm_data2fit(@color_gamma_4d_data2fit, s, paths.mfs_fn, opt);
end
% if (opt.do_fit2param)
%     mdm_fit2param(@dti_euler_4d_fit2param, paths.mfs_fn, paths.dps_fn, opt);
% end
% 
% % Save nifti parameter maps    
% if (opt.do_param2nii)
%     fn = mdm_param2nii(paths.dps_fn, paths.nii_path, opt.dti_euler, opt);
% end
% 


