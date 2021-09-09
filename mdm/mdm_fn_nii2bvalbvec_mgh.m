function [bval_fn, bvec_fn] = mdm_fn_nii2bvalbvec_mgh(nii_fn)
% function [bval_fn, bvec_fn] = mdm_fn_nii2bvalbvec_mgh(nii_fn)
%
% convert a filename ending in .nii or .nii.gz to two files ending in
% .bval and .bvec

% very custom code for the MGH data release in HCP DB

[nii_path, nii_name] = msf_fileparts(nii_fn);


nii_name = strrep(nii_name, 'diff_', '');


bval_fn = fullfile(nii_path, ['bvals_' nii_name '.txt']);
bvec_fn = fullfile(nii_path, ['bvecs_' nii_name '.txt']);
