function fn = dtr2d_spen_pipe(s, paths, opt)
% function fn = dtr2d_pipe(s, paths, opt)
%
% s     - input structure
% paths - either a pathname or a path structure (see mdm_paths)
% opt   - (optional) options that drive the pipeline
%
% fn    - a cell array with filenames to generated nii files

fn = '';

if (nargin < 3), opt.present = 1; end

opt = mdm_opt(opt);
opt = dtr2d_opt(opt);
paths = mdm_paths(paths);
msf_log(['Starting ' mfilename], opt);


% Prepare: mask etc
if (opt.do_mask)
    s = mdm_s_mask(s, @mio_mask_threshold, [], opt);
end

% Run the analysis
if (opt.do_data2fit)
    mdm_data2fit(@dtr2d_spen_4d_data2fit, s, paths.mfs_fn, opt);
end
% if (opt.do_fit2param)
%     mdm_fit2param(@dtr2d_4d_fit2param, paths.mfs_fn, paths.dps_fn, opt);
% end
% 
% % Save nifti parameter maps    
% if (opt.do_param2nii)
%     fn = mdm_param2nii(paths.dps_fn, paths.nii_path, opt.dtr2d, opt);
%     % Convert all .nii.gz files to .pdf
%     if (opt.do_nii2pdf)
%         mdm_nii2pdf(fn, [], opt);
%     end
% end
% 
% % Save dtr2d pdf   
% if (opt.do_m2pdf)
%     dtr2d_m2pdf(paths.dps_fn, paths.nii_path, opt);
% end



