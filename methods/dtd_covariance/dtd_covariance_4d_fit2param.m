function dps = dtd_covariance_4d_fit2param(mfs_fn, dps_fn, opt)
% function dps = dtd_covariance_4d_fit2param(mfs_fn, dps_fn, opt)
%
% Compute dps (display parameters structure) from the mfs (model fit
% structure) using functions tm_dt_to_dps and tm_ct_to_dps

if (nargin < 2), mfs_fn = []; end
if (nargin < 3), opt    = []; end

opt = mdm_opt(opt);
mfs = mdm_mfs_load(mfs_fn);
sz  = msf_size(mfs.m(:,:,:,1), 3);

% reshape help functions
g = @(a,n) reshape(a, prod(sz(1:3)), n);
f = @(a,n) reshape(a, sz(1), sz(2), sz(3), n);

% Preliminary hack to get powder-averaged data into this structure
if (size(mfs.m, 4) == 4) % assume data was analyzed via the pa pipe
    
    % The dki_pa model yields MD, V_I, and V_A
    % Convert these to an isotropic dt and isotropic tensor covariance tensor
    % Note that V_A = 2/5 * < V_lambda[D] > 
    % [see Szczepankiewicz thesis Eq. 9]
    % We want V_lambda represented in the covariance tensor
  
    [E4_bulk, E4_shear] = tm_1x21_iso();
    E2_iso = [1 1 1 0 0 0]/3;
    
    h = @(x) x / tm_inner(x,x); % use normalized bases

    mfs.m = cat(4, ...
        mfs.m(:,:,:,1), ...
        f(g(mfs.m(:,:,:,2),1) .* repmat(h(E2_iso),   prod(sz(1:3)),1), 6), ...
        f(g(1/1 * mfs.m(:,:,:,3),1) .* repmat(h(E4_bulk),  prod(sz(1:3)),1), 21) + ...
        f(g(5/2 * mfs.m(:,:,:,4),1) .* repmat(h(E4_shear), prod(sz(1:3)),1), 21));
        
end

% init dps
dps.nii_h = mfs.nii_h;
dps.mask  = mfs.mask;

% get data from input
dps.s0  = mfs.m(:,:,:,1);

% diffusion tensor
dt_1x6 = g(mfs.m(:,:,:,2:7), 6) * 1e9;
dps   = tm_dt_to_dps(dt_1x6, dps, f);

% covariance tensor
ct_1x21  = g(mfs.m(:,:,:,8:28), 21) * 1e18;
dps = tm_ct_to_dps(ct_1x21, dps, f);

% Clamp kurtosis measures
dps.MKi  = mio_min_max_cut(dps.MKi, 0.0, 4.0); 
dps.MKa  = mio_min_max_cut(dps.MKa, 0.0, 4.0); 
dps.MKt  = mio_min_max_cut(dps.MKt, 0.0, 4.0); 
dps.MK   = mio_min_max_cut(dps.MK,  0.0, 4.0); 
dps.MKad = mio_min_max_cut(dps.MKad, 0.0, 4.0); 
dps.MKd  = mio_min_max_cut(dps.MKd, 0.0, 4.0); 


if (~isempty(dps_fn))
    mdm_dps_save(dps, mfs.s, dps_fn, opt);
end





