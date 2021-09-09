function fn = dtd_smr_pipe(s, paths, opt)
% function fn = dtd_smr_pipe(s, paths, opt)
%
% s     - input structure
% paths - either a pathname or a path structure (see mdm_paths)
% opt   - (optional) options that drive the pipeline
%            opt.mask.thresh = 0.1, you may want to adjust it 
%            
%
% fn    - a cell arary with filenames to generated nii files

if (nargin < 2), paths = fileparts(s.nii_fn); end
if (nargin < 3), opt.present = 1; end

% Init structures
opt         = mdm_opt(opt);
opt.dtd_smr.present = 1;
opt.dtd_smr = dtd_smr_opt(opt.dtd_smr);
paths = mdm_paths(paths, opt.dtd_smr.fig_prefix);     

msf_log(['Starting ' mfilename], opt);    

% Smooth and prepare mask
if (opt.filter_sigma > 0)
    s = mdm_s_smooth(s, opt.filter_sigma, fileparts(s.nii_fn), opt);
end
s = mdm_s_mask(s, @mio_mask_threshold, fileparts(s.nii_fn), opt);

% Fit and derive parameters
mdm_data2fit(@dtd_smr_4d_data2fit, s, paths.mfs_fn, opt);

mdm_fit2param(@dtd_smr_4d_fit2param, paths.mfs_fn, paths.dps_fn, opt);

% Save niftis
fn = mdm_param2nii(paths.dps_fn, paths.nii_path, opt.dtd_smr, opt); 

