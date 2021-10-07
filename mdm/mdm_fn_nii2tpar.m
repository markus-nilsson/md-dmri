function nii_fn = mdm_fn_nii2tpar(nii_fn)
% function nii_fn = mdm_fn_nii2mc(nii_fn)

[a,b,c] = msf_fileparts(nii_fn);

nii_fn = [a filesep b '_tpar.mat'];

