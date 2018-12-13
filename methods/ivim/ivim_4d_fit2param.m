function dps = ivim_4d_fit2param(mfs_fn, dps_fn, opt)
% function dps = ivim_4d_fit2param(mfs_fn, dps_fn, opt)
%
% this function should be more coordinated with dti_nls

if (nargin < 2), mfs_fn = []; end
if (nargin < 3), opt = []; end

opt = mdm_opt(opt);
mfs = mdm_mfs_load(mfs_fn);

% init dps
dps.nii_h = mfs.nii_h;
dps.mask  = mfs.mask;

% compute md, fa, and color fa
dps.s0       = mfs.m(:,:,:,1);
dps.f_blood  = mfs.m(:,:,:,2);
dps.D_blood  = mfs.m(:,:,:,3);
dps.D_tissue = mfs.m(:,:,:,4);

if (~isempty(dps_fn))
    mdm_dps_save(dps, mfs.s, dps_fn, opt);
end


