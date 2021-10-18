function [sout, status, result] = mdm_s_mrtrix_degibbs(s, nii_fn_out, opt)
% function [sout, status, result] = mdm_s_mrtrix_degibbs(s, nii_fn_out, opt)
%
% https://mrtrix.readthedocs.io/en/latest/reference/commands/mrdegibbs.html
% 
% This function requires that MRTRIX is installed on your computer. Please
% see installation instructions: 
% https://mrtrix.readthedocs.io/en/latest/installation/package_install.html

if nargin < 2 || isempty(nii_fn_out)
    nii_fn_out = mdm_fn_nii2dg(s.nii_fn);
end

if nargin < 3 || isempty(opt)
    opt = mdm_mrtrix_opt;
end


[status, result] = mdm_mrtrix_degibbs(s.nii_fn, nii_fn_out, opt);


% Copy input xps to output xps
mdm_xps_save(s.xps, mdm_xps_fn_from_nii_fn(nii_fn_out), opt);

sout.nii_fn = nii_fn_out;
sout.xps    = s.xps;

if isfield(s, 'mask_fn')
    sout.mask_fn = s.mask_fn;
end