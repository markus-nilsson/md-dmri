function [I,h] = mdm_nii_read_and_rescale(nii_fn)
% function [I,h] = mdm_nii_read_and_rescale(nii_fn)

[I,h] = mdm_nii_read(nii_fn);

I = single(h.scl_inter) + single(h.scl_slope) * single(I);

h.scl_inter = 0;
h.scl_slope = 1;