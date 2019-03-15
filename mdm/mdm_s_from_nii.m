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
s.xps = mdm_xps_from_nii_fn(nii_fn, b_delta);

if (~msf_isfield(s.xps, 'b_eta'))
    s.xps.b_eta = zeros(s.xps.n, 1);
end