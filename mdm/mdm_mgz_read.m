function [I, h] = mdm_mgz_read(mgz_fn)
% function [I, h] = mdm_mgz_read(mgz_fn)

% requires that freesurfer is on the path

mri = MRIread(mgz_fn);

I = mri.vol;

h = mdm_nii_h_empty;