function dps = dtd_4d_fit2param(mfs_fn, dps_fn, opt)
% function dps = dtd_4d_fit2param(mfs_fn, dps_fn, opt)

if (nargin < 2), dps_fn = []; end
if (nargin < 3), opt = []; end

opt = mdm_opt(opt);
opt = dtd_opt(opt);
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

[dpar,dperp,theta,phi,w] = dtd_4d_m2pars(m);

sz = size(m);
nn = size(dpar,4);


%Calculate derived parameters
[dxx,dyy,dzz,dxy,dxz,dyz] = dtd_pars2elements(dpar,dperp,theta,phi);
[diso,daniso,dratio,ddelta,sdaniso,sddelta] = dtd_pars2dpars(dpar,dperp);

dtds = struct('w',w,'dpar',dpar,'dperp',dperp,'theta',theta,'phi',phi,'diso',diso,'daniso',daniso,'ddelta',ddelta,...
    'sdaniso',sdaniso,'sddelta',sddelta,'dratio',dratio,'dxx',dxx,'dyy',dyy,'dzz',dzz,'dxy',dxy,'dxz',dxz,'dyz',dyz);

dps = dtd_dtds2dps(dps, dtds);

%Per-bin statistical measures
for nbin = 1:numel(opt.dtd.bin_disomax)    
    ind_bin = false([sz(1) sz(2) sz(3) nn 6]);
    ind_bin(:,:,:,:,1) = diso >= opt.dtd.bin_disomin(nbin);
    ind_bin(:,:,:,:,2) = diso <= opt.dtd.bin_disomax(nbin);
    ind_bin(:,:,:,:,3) = dratio >= opt.dtd.bin_dratiomin(nbin);
    ind_bin(:,:,:,:,4) = dratio <= opt.dtd.bin_dratiomax(nbin);
    ind_bin(:,:,:,:,5) = sddelta >= opt.dtd.bin_sddeltamin(nbin);
    ind_bin(:,:,:,:,6) = sddelta <= opt.dtd.bin_sddeltamax(nbin);
    ind_bin = all(ind_bin,5);

    dps_bin.no = nbin;
    dtds_temp = dtds;
    dtds_temp.w = dtds.w.*ind_bin;
    dps_bin = dtd_dtds2dps(dps_bin, dtds_temp);
    dps_bin.f = dps_bin.s0./dps.s0;
    dps.bin{nbin} = dps_bin;
end

if (~isempty(dps_fn)) mdm_dps_save(dps, dps.s, dps_fn, opt); end

end

