function dps = dki_lls_4d_fit2param(mfs_fn, dps_fn, opt)
% function dps = dki_lls_4d_fit2param(mfs_fn, dps_fn, opt)
%
% Compute dps (display parameters structure) from the mfs (model fit
% structure) using functions tm_dt_to_dps and tm_kt_to_dps

if (nargin < 2), mfs_fn = []; end
if (nargin < 3), opt    = []; end

opt = mdm_opt(opt);
mfs = mdm_mfs_load(mfs_fn);
sz  = msf_size(mfs.m(:,:,:,1), 3);

% reshape help functions
g = @(a,n) reshape(a, prod(sz(1:3)), n);
f = @(a,n) reshape(a, sz(1), sz(2), sz(3), n);

% init dps
dps.nii_h = mfs.nii_h;
dps.mask  = mfs.mask;

% pull out s0
dps.s0  = mfs.m(:,:,:,1);

% pull out diffusion tensor, convert to parameters and add to 
% the display parameter structure (dps)
dt_1x6  = g(mfs.m(:,:,:,2:7), 6) * 1e9;
dps     = tm_dt_to_dps(dt_1x6, dps, f);

% pull out a kind of a covariance tensor with some elements being mixed up
% (e.g. C_xyxy is mixed with C_xxyy) (this is the kurtosis tensor)
kt_1x15 = g(mfs.m(:,:,:,8:22), 15) * 1e18;
dps     = tm_kt_to_dps(kt_1x15, dps, f);

if (~isempty(dps_fn))
    mdm_dps_save(dps, mfs.s, dps_fn, opt);
end