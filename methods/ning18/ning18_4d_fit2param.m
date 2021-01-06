function dps = ning18_4d_fit2param(mfs_fn, dps_fn, opt)
% function dps = ning18_4d_fit2param(mfs_fn, dps_fn, opt)
%
% Compute dps (display parameters structure) from the mfs (model fit
% structure) using functions tm_dt_to_dps and tm_kt_to_dps

if (nargin < 2), mfs_fn = []; end
if (nargin < 3), opt    = []; end

opt = mdm_opt(opt);
mfs = mdm_mfs_load(mfs_fn);

% init dps
dps.nii_h = mfs.nii_h;
dps.mask  = mfs.mask;

% pull out parameters
dps.s0  = mfs.m(:,:,:,1);
dps.MD  = mfs.m(:,:,:,2) * 1e9;
dps.V   = mfs.m(:,:,:,3) * 1e18;
dps.Vk  = mfs.m(:,:,:,4) * 1e18;
dps.msr = mfs.m(:,:,:,5);
%
dps.MK  = 3 * dps.V ./ (dps.MD.^2 + eps);
%
dps.k   = dps.Vk    ./ (dps.V     + eps);
dps.tau = dps.V     ./ (dps.Vk    + eps); % 1 / k
dps.MKk = dps.MK    .* dps.k;
%

if (~isempty(dps_fn))
    mdm_dps_save(dps, mfs.s, dps_fn, opt);
end


