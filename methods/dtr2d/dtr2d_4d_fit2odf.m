function odf = dtr2d_4d_fit2odf(mfs_fn, odf_fn, opt)
% function odf = dtr2d_4d_fit2odf(mfs_fn, odf_fn, opt)

if (nargin < 2), dps_fn = []; end
if (nargin < 3), opt = []; end

opt = mdm_opt(opt);
opt = dtd_opt(opt);
mfs = mdm_mfs_load(mfs_fn);

% create parameter maps and save them

m = mfs.m;
sz = size(m);

ind = false(sz(4),1);
ind(2:6:end) = 1;
nn = (sz(4)-1)/6;

dpar = m(:,:,:,circshift(ind,0,1));
dperp = m(:,:,:,circshift(ind,1,1));
theta = m(:,:,:,circshift(ind,2,1));
phi = m(:,:,:,circshift(ind,3,1));
r2 = m(:,:,:,circshift(ind,4,1));
w = m(:,:,:,circshift(ind,5,1));
if isfield(opt.dtr2d,'r2extrap') == 1
    w = w.*exp(-r2*opt.dtr2d.r2extrap);
end

%Calculate derived parameters
diso = (dpar + 2*dperp)/3;
daniso = (dpar - dperp)/3;
ddelta = msf_notfinite2zero(daniso./diso);
sdaniso = daniso.^2;
sddelta = msf_notfinite2zero(sdaniso./diso.^2);
dratio = msf_notfinite2zero(dpar./dperp);
[dxx,dyy,dzz,dxy,dxz,dyz] = dtd_pars2elements(dpar,dperp,theta,phi);

dtds = struct('w',w,'dpar',dpar,'dperp',dperp,'theta',theta,'phi',phi,'diso',diso,'daniso',daniso,'ddelta',ddelta,...
    'sdaniso',sdaniso,'sddelta',sddelta,'dratio',dratio,'dxx',dxx,'dyy',dyy,'dzz',dzz,'dxy',dxy,'dxz',dxz,'dyz',dyz);

%ODF nodes
run_path = mfilename('fullpath');
framework_path = fileparts(fileparts(fileparts(run_path)));
angles_path = fullfile(framework_path,'tools','uvec','repulsion_angles_tri');

odf_s.n = opt.dtr2d.odf_nnodes;
angles = load(fullfile(angles_path,num2str(odf_s.n)));
odf_s.x = sin(angles.theta).*cos(angles.phi);
odf_s.y = sin(angles.theta).*sin(angles.phi);
odf_s.z = cos(angles.theta);
odf_s.tri = angles.tri;
ODindex = opt.dtr2d.odf_watsonkappa; %Watson distribution smoothing kernel
odf_s.kappa = 1/tan(ODindex*pi/2);

    function odf_w = dtds2odf(odf_s, dtds)
        odf_w = zeros(sz(1), sz(2), sz(3), odf_s.n);

        for nk = 1:sz(3)
            for nj = 1:sz(2)
                for ni = 1:sz(1)
                    if mfs.mask(ni,nj,nk)
                        %[ni nj nk]
%                        if n>0
                            theta_vox = squeeze(dtds.theta(ni,nj,nk,:));
                            phi_vox = squeeze(dtds.phi(ni,nj,nk,:));
                            w_vox = squeeze(dtds.w(ni,nj,nk,:));
                            odf_d.x = sin(theta_vox).*cos(phi_vox);
                            odf_d.y = sin(theta_vox).*sin(phi_vox);
                            odf_d.z = cos(theta_vox);
                            odf_d.w = w_vox;
                            odf_vox = dist_odf_discrete2smooth(odf_d,odf_s);
                            odf_w(ni,nj,nk,:) = odf_vox.w(:);   
%                        end
                     end
                end
            end
        end

        %odf_s.norms = vertexNormal(triangulation(odf_s.tri,odf_s.verts),(1:odf_s.n)');
    end

odf = odf_s;
%odf_w = dtds2odf(odf_s, dtds);
%odf.w = odf_w;

%Per-bin ODFs
for nbin = 1:numel(opt.dtr2d.bin_disomax)
    ind_bin = false([sz(1) sz(2) sz(3) nn 4]);
    ind_bin(:,:,:,:,1) = diso >= opt.dtr2d.bin_disomin(nbin);
    ind_bin(:,:,:,:,2) = diso <= opt.dtr2d.bin_disomax(nbin);
    ind_bin(:,:,:,:,3) = dratio >= opt.dtr2d.bin_dratiomin(nbin);
    ind_bin(:,:,:,:,4) = dratio <= opt.dtr2d.bin_dratiomax(nbin);
    ind_bin = all(ind_bin,5);

    odf_bin.no = nbin;
    dtds_temp = dtds;
    dtds_temp.w = dtds.w.*ind_bin;
    odf_w = dtds2odf(odf_s, dtds_temp);
    odf.w_bin{nbin} = odf_w;
end

% if (~isempty(odf_fn))
%     % Save data
%     msf_mkdir(fileparts(odf_fn));
%     save(odf_fn, 'odf');
% end

end

