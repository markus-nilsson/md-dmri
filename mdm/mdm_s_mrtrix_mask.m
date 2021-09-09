function [sout, status, result] = mdm_s_mrtrix_mask(s, nii_fn_out, opt)
% function [sout, status, result] = mdm_s_mrtrix_mask(s, nii_fn_out, opt)
%
% https://mrtrix.readthedocs.io/en/latest/reference/commands/dwi2mask.html
% 
% This function requires that MRTRIX is installed on your computer. Please
% see installation instructions: 
% https://mrtrix.readthedocs.io/en/latest/installation/package_install.html

if nargin < 2 || isempty(nii_fn_out)
    nii_fn_out = mdm_fn_nii2mask(s.nii_fn);
end

if nargin < 3 || isempty(opt)
    opt = mdm_mrtrix_opt;
end

[status, result] = mdm_mrtrix_mask(s.nii_fn, nii_fn_out, opt);

sout = s;
sout.mask_fn = nii_fn_out;