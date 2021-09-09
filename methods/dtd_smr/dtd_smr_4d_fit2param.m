function dps = dtd_smr_4d_fit2param(mfs_fn, dps_fn, opt)
% function dps = dtd_smr_4d_fit2param(mfs_fn, dps_fn, opt)

if (nargin < 2), dps_fn = []; end
if (nargin < 3), opt = []; end

opt = mdm_opt(opt);
dps = mdm_mfs_load(mfs_fn);

% Create parameter maps
%
dps.s0    =                  dps.m(:,:,:,1);
dps.fs    = mio_min_max_cut( dps.m(:,:,:,2)  * 1  , [0 1]);
dps.di_s  = mio_min_max_cut( dps.m(:,:,:,3)  * 1e9, [0 4]);
dps.di_z  = mio_min_max_cut( dps.m(:,:,:,4)  * 1e9, [0 4]);
dps.dd_z  = mio_min_max_cut( dps.m(:,:,:,5)  * 1  , [-0.5 1]);
p         = sqrt(5 / (4*pi)); 
dps.p20   = mio_min_max_cut( dps.m(:,:,:,6)  * 1  , [-p p]);
dps.p21r  = mio_min_max_cut( dps.m(:,:,:,7)  * 1  , [-p p]);
dps.p21i  = mio_min_max_cut( dps.m(:,:,:,8)  * 1  , [-p p]);
dps.p22r  = mio_min_max_cut( dps.m(:,:,:,9)  * 1  , [-p p]);
dps.p22i  = mio_min_max_cut( dps.m(:,:,:,10) * 1  , [-p p]);
dps.t2_s  = mio_min_max_cut( dps.m(:,:,:,11) * 1e3, [0 1e3]);
dps.t2_z  = mio_min_max_cut( dps.m(:,:,:,12) * 1e3, [0 1e3]);
dps.ssr   = dps.m(:,:,:,13);

%
% Calculate the p2 invariant
ind     = dps.mask > 0;
p2m     = [dps.p20(ind) dps.p21r(ind) dps.p21i(ind) dps.p22r(ind) dps.p22i(ind)];
tmp     = zeros(size(dps.mask));
tmp(ind) = smr_px2p2(p2m);
dps.p2  = tmp; 

% Provide some parameter conversions
%
dps.da_s  = mio_min_max_cut( dps.m(:,:,:,3)  * 3e9                              , [0 4]);
dps.da_z  = mio_min_max_cut( dps.m(:,:,:,4)  * 1e9 .* (1 + 2 * dps.m(:,:,:,5))  , [0 4]);
dps.dr_z  = mio_min_max_cut( dps.m(:,:,:,4)  * 1e9 .* (1 - 1 * dps.m(:,:,:,5))  , [0 4]);

% Calculate T2
%
fs          = dps.m(:,:,:,2);
r2s         = 1 ./ (dps.m(:,:,:,11) + eps);
r2z         = 1 ./ (dps.m(:,:,:,12) + eps);
r2          = (fs .* r2s + (1 - fs) .* r2z);
t2          =  (1 ./ r2) .* dps.mask;
dps.t2      = mio_min_max_cut(t2 * 1e3 , [0 1e3]);

if (~isempty(dps_fn))
    mdm_dps_save(dps, dps.s, dps_fn, opt);
end

