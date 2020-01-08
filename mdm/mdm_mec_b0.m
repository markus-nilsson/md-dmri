function s = mdm_mec_b0(s, p_fn, o_path, opt)
% function s = mdm_mec_b0(s, p_fn, o_path, opt)
% 
% Perform motion and eddy currect correction by registering to b0
%
% s      - input structure OR a nii_fn with xps computed from it
% p_fn   - parameter filename, to elastix registration scheme
% o_path - output path for the new files
% opt    - options (optional)
%
% Output
% s - s.nii_fn will be updated to refer to the corrected volume

if (nargin < 3), o_path = fileparts(s.nii_fn); end
if (nargin < 4), opt.present = 1; end
opt = mio_opt(opt);
msf_log(['Starting ' mfilename], opt);

% convert nii_fn to s if needed
if (all(ischar(s))), s = mdm_nii_to_s(s); end

% build file names
[~,name] = msf_fileparts(s.nii_fn);
ref_fn = fullfile(o_path, [name '_ref' opt.nii_ext]);

% save the volume with lowest b0 as the reference
if (~exist(ref_fn, 'file') || (opt.do_overwrite))
    [I,h] = mdm_nii_read(s.nii_fn);
    [~,c_b0] = min(s.xps.b);
    mdm_nii_write(I(:,:,:,c_b0), ref_fn, h);
else   
    opt.mdm.mec.do_cleanup = 0; % don't clean up files not created here
end


[s.nii_fn, tpm_fn] = mdm_coreg(s.nii_fn, ref_fn, p_fn, o_path, opt);

if (opt.mdm.mec.do_rotate_bvec)
    s.xps = mdm_mec_rotate_bvec(s.xps, tpm_fn, p_fn);
end

mdm_xps_save(s.xps, mdm_xps_fn_from_nii_fn(s.nii_fn));


% Cleanup?
if (opt.mdm.mec.do_cleanup)
    msf_delete(ref_fn);    
end

