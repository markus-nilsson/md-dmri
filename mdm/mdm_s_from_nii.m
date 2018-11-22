function s = mdm_s_from_nii(nii_fn, b_delta)
% function s = mdm_s_from_nii(nii_fn, b_delta)
%
% nii_fn  -- nifti file name
% b_delta -- force xps to be constructed with this filename
%
% converts a nii_fn to an input structure with two fields
%
% s.nii_fn
% s.xps
%
% assumes the xps filename can be constructred from the nii_fn

if (nargin < 2), b_delta = 1; end

s.nii_fn = nii_fn;

if (exist(mdm_xps_fn_from_nii_fn(nii_fn), 'file'))
    
    s.xps = mdm_xps_load(mdm_xps_fn_from_nii_fn(nii_fn));
    
elseif (exist(mdm_fn_nii2gdir(nii_fn), 'file'))
    
    % Lund-generated gdir file
    s.xps = mdm_xps_from_gdir(mdm_fn_nii2gdir(nii_fn), [], b_delta);

elseif (exist(mdm_fn_nii2bvalbvec(nii_fn), 'file'))

    % Conventional bval bvec from dcm2nii
    [a,b] = mdm_fn_nii2bvalbvec(nii_fn);
    s.xps = mdm_xps_from_bval_bvec(a,b, b_delta);
    
else
    
    error('Missing xps');   

end

if (~msf_isfield(s.xps, 'b_eta'))
    s.xps.b_eta = zeros(s.xps.n, 1);
end