function xps = mdm_xps_from_nii_fn(nii_fn, b_delta)
% function xps = mdm_xps_from_nii_fn(nii_fn, b_delta)
%
% Try to find meta-data from nii_fn, by finding match in descending order
% 1. xps
% 2. gdir
% 3. bval/bvec
if (nargin < 2)
    error('need to know b-delta for this to work');
end

if (exist(mdm_xps_fn_from_nii_fn(nii_fn), 'file'))
    
    xps = mdm_xps_load(mdm_xps_fn_from_nii_fn(nii_fn));
    
elseif (exist(mdm_fn_nii2gdir(nii_fn), 'file'))
    
    % Lund-generated gdir file
    xps = mdm_xps_from_gdir(mdm_fn_nii2gdir(nii_fn), [], b_delta);

elseif (exist(mdm_fn_nii2bvalbvec(nii_fn), 'file'))

    % Conventional bval bvec from dcm2nii
    [a,b] = mdm_fn_nii2bvalbvec(nii_fn);
    xps = mdm_xps_from_bval_bvec(a,b, b_delta);
    
else
    
    error('Missing xps');   

end
