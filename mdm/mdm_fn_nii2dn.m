function nii_fn = mdm_fn_nii2dn(nii_fn)
% function nii_fn = mdm_fn_nii2dn(nii_fn)

[a,b,c] = msf_fileparts(nii_fn);

nii_fn = [a filesep b '_dn' c];

