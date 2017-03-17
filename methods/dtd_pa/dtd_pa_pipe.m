function fn = dtd_pa_pipe(s, paths, opt)
% function fn = dtd_pa_pipe(s, paths, opt)
%
% s     - input structure
% paths - either a pathname or a path structure (see mdm_paths)
% opt   - (optional) options that drive the pipeline
%
% fn    - a cell array with filenames to generated nii files

fn = '';

if (nargin < 3), opt.present = 1; end

opt   = mdm_opt(opt);
opt   = dtd_pa_opt(opt);
paths = mdm_paths(paths);
msf_log(['Starting ' mfilename], opt);

% Prepare: mask etc
s = mdm_s_mask(s, @mio_mask_threshold, [], opt);
s = mdm_s_powder_average(s, fileparts(s.nii_fn), opt);

% Run the analysis
if (opt.do_data2fit)
    mdm_data2fit(@dtd_pa_4d_data2fit, s, paths.mfs_fn, opt);
    mdm_fit2param(@dtd_pa_4d_fit2param, paths.mfs_fn, paths.dps_fn, opt);

% Save nifti parameter maps
    fn = mdm_param2nii(paths.dps_fn, paths.nii_path, opt.dtd_pa, opt);
end

% Save dtd pdf   
if (opt.do_dtdpdf)
    dtd_pa_mkpdf(paths.dps_fn, paths.nii_path, opt);
end


