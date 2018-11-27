function s = mdm_mec_eb(s_target, s_source, p_fn, o_path, opt)
% function s = mdm_mec_eb(s_target, s_source, p_fn, o_path, opt)
% 
% Perform motion and eddy currect correction by registering to extrapolated
% references
%
% s_target  - input structure for target data OR a nifti filename
% s_source  - input structure for source data (should be low b-values) 
%                               OR a nifti filename
% p_fn      - parameter filename, to elastix registration scheme
% o_path    - output path for the new files
% opt       - options (optional)
%
% Output
% s - s.nii_fn will be updated to refer to the corrected volume


% init
if (nargin < 4), o_path = fileparts(s_target.nii_fn); end
if (nargin < 5), opt.present = 1; end
opt = mdm_opt(opt);
msf_log(['Starting ' mfilename], opt);


% convert nii to s
if (all(ischar(s_target))), s_target = mdm_nii_to_s(s_target); end
if (all(ischar(s_source))), s_source = mdm_nii_to_s(s_source); end

[~,name]    = msf_fileparts(s_target.nii_fn);
ref_fn      = fullfile(o_path, [name '_ref' opt.nii_ext]);

% make reference
if (~exist(ref_fn, 'file') || opt.do_overwrite)
    msf_log('Making reference', opt);
    
    % load source data (do conventional MC first)
    [I,h] = mdm_nii_read(s_source.nii_fn);
    M = mdm_mask_load(s_source);
        
    % Create reference, improve fitting by some initial smoothing
    I     = mio_smooth_4d(single(I), 0.6);
    ind   = s_source.xps.b < opt.mdm.mec_eb.b_limit; % limit to low b-values
    I_ref = mio_ref_extrapolate(I, s_source.xps, s_target.xps, M, ind, opt);
        
    % Rescale for easier comparisons
    I_true = mdm_nii_read(s_target.nii_fn);
    
    if (numel(I_true) == numel(I_ref))
        I_ref  = mio_rescale(I_ref, I_true, M);
    end
        
    % Save output
    msf_delete(ref_fn);
    mdm_nii_write(single(I_ref), ref_fn, h);        
end

% Run coregistration
s = s_target;
[s.nii_fn, tpm_fn] = mdm_coreg(s.nii_fn, ref_fn, p_fn, o_path, opt);

if (opt.mdm.mec.do_rotate_bvec)
    s.xps = mdm_mec_rotate_bvec(s.xps, tpm_fn, p_fn);
end

mdm_xps_save(s.xps, mdm_xps_fn_from_nii_fn(s.nii_fn));

