function [status, result] = mdm_mrtrix_degibbs(nii_fn_in, nii_fn_out, opt)
% function [status, result] = mdm_mrtrix_degibbs(nii_fn_in, nii_fn_out, opt)
%
% https://mrtrix.readthedocs.io/en/latest/reference/commands/mrdegibbs.html
% 
% This function requires that MRTRIX is installed on your computer. Please
% see installation instructions: 
% https://mrtrix.readthedocs.io/en/latest/installation/package_install.html

cmd = 'mrdegibbs';
cmd = [cmd ' "' nii_fn_in '"']; % input
cmd = [cmd ' "' nii_fn_out '"']; % output


if ~opt.verbose
    cmd = [cmd ' -quiet']; % noise map
end

if opt.do_overwrite
    cmd = [cmd ' -force']; % noise map
end

[status, result] = msf_system(cmd);

