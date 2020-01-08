function s_mec = mdm_s_mec(s, p_fn, o_path, opt)
% function s_mec = mdm_s_mec(s, p_fn, o_path, opt)
% 
% Perform motion and eddy currect correction by registering to extrapolated
% references. This method first registeres low b-value data to b0 and then 
% use this data to extrapolate data, which will act as the target images in
% the final registration. 
% 
% See Nilsson et al (2015) Plos One
% https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0141825
%
% Mandatory arguments
% s         - reference to data (s.nii_fn, s.xps are reqiured fields)
%
% Optional arguments
% p_fn      - parameter filename, to elastix registration scheme
% o_path    - output path for the new files
% opt       - options (optional)
%
% Output
% s_mec - s_mec.nii_fn will be updated to refer to the corrected volume

if (nargin < 2)
    p_fn = elastix_p_write(elastix_p_affine(200), ...
        fullfile(fileparts(s.nii_fn), 'p.txt'));
end
    
if (nargin < 3), o_path = fileparts(s.nii_fn); end
if (nargin < 4), opt.present = 1; end
opt = mdm_opt(opt);
msf_log(['Starting ' mfilename], opt);

% Define which data to include in the reference (only low b-value data)
s_sub = mdm_s_subsample(s, s.xps.b <= opt.mdm.mec_eb.b_limit, o_path, opt); 

% First run a conventional registration to b0 of the reference
s_sub_mc = mdm_mec_b0(s_sub, p_fn, o_path, opt);

% Run an extrapolation-based registration
s_mec = mdm_mec_eb(s, s_sub_mc, p_fn, o_path, opt);

% Delete intermediate files
if (opt.mdm.mec.do_cleanup)
    
    msf_delete(s_sub.nii_fn);
    msf_delete(mdm_xps_fn_from_nii_fn(s_sub.nii_fn));
    
    msf_delete(s_sub_mc.nii_fn);
    msf_delete(mdm_xps_fn_from_nii_fn(s_sub_mc.nii_fn));    
end

