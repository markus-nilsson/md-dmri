function nii_fn = mdm_fn_nii2dg(nii_fn)
% function nii_fn = mdm_fn_nii2dg(nii_fn)

[a,b,c] = msf_fileparts(nii_fn);

nii_fn = [a filesep b '_dg' c];

