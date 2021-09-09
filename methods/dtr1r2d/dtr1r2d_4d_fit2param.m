function dps = dtr1r2d_4d_fit2param(mfs_fn, dps_fn, opt)
% function dps = dtr1r2d_4d_fit2param(mfs_fn, dps_fn, opt)

if (nargin < 2), dps_fn = []; end
if (nargin < 3), opt = []; end

opt = mdm_opt(opt);
opt = dtr1r2d_opt(opt);
%dps = mdm_mfs_load(mfs_fn);

% Hack to allow mgui to access this function
if ischar(mfs_fn)
    dps = mdm_mfs_load(mfs_fn);
else
    m = mfs_fn;
    dps.m = m;
end

% create parameter maps and save them

m = dps.m;
dps = rmfield(dps,'m');

[dpar,dperp,theta,phi,r1,r2,w] = dtr1r2d_4d_m2pars(m);

sz = size(m);
nn = size(dpar,4);

%Calculate derived parameters
[dxx,dyy,dzz,dxy,dxz,dyz] = dtd_pars2elements(dpar,dperp,theta,phi);
[diso,daniso,dratio,ddelta,sdaniso,sddelta] = dtd_pars2dpars(dpar,dperp);

dtr1r2ds = struct('w',w,'dpar',dpar,'dperp',dperp,'theta',theta,'phi',phi,'diso',diso,'daniso',daniso,'ddelta',ddelta,...
    'sdaniso',sdaniso,'sddelta',sddelta,'dratio',dratio,'dxx',dxx,'dyy',dyy,'dzz',dzz,'dxy',dxy,'dxz',dxz,'dyz',dyz,'r1',r1,'r2',r2);

dps = dtr1r2d_dtr1r2ds2dps(dps, dtr1r2ds);

% reshape help functions
sz_reshape  = msf_size(m(:,:,:,1), 3);
g_reshape = @(a,n) reshape(a, prod(sz_reshape(1:3)), n);
f_reshape = @(a,n) reshape(a, sz_reshape(1), sz_reshape(2), sz_reshape(3), n);
dt = cat(4,dps.mdxx,dps.mdyy,dps.mdzz,dps.mdxy,dps.mdxz,dps.mdyz);
dps = tm_dt_to_dps(g_reshape(dt, 6)*1e9, dps, f_reshape, 0.0001);

%Per-bin statistical measures
for nbin = 1:numel(opt.dtr1r2d.bin_disomax)    
    ind_bin = false([sz(1) sz(2) sz(3) nn 8]);
    ind_bin(:,:,:,:,1) = diso >= opt.dtr1r2d.bin_disomin(nbin);
    ind_bin(:,:,:,:,2) = diso <= opt.dtr1r2d.bin_disomax(nbin);
    ind_bin(:,:,:,:,3) = dratio >= opt.dtr1r2d.bin_dratiomin(nbin);
    ind_bin(:,:,:,:,4) = dratio <= opt.dtr1r2d.bin_dratiomax(nbin);
    ind_bin(:,:,:,:,5) = sddelta >= opt.dtr1r2d.bin_sddeltamin(nbin);
    ind_bin(:,:,:,:,6) = sddelta <= opt.dtr1r2d.bin_sddeltamax(nbin);
    ind_bin(:,:,:,:,7) = r1 >= opt.dtr1r2d.bin_r1min(nbin);
    ind_bin(:,:,:,:,8) = r1 <= opt.dtr1r2d.bin_r1max(nbin);
    ind_bin = all(ind_bin,5);

    dps_bin.no = nbin;
    dtr1r2ds_temp = dtr1r2ds;
    dtr1r2ds_temp.w = dtr1r2ds.w.*ind_bin;
    dps_bin = dtr1r2d_dtr1r2ds2dps(dps_bin, dtr1r2ds_temp);
    dps_bin.f = dps_bin.s0./dps.s0;
    dps.bin{nbin} = dps_bin;
end

if (~isempty(dps_fn)) mdm_dps_save(dps, dps.s, dps_fn, opt); end

end

