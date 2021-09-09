function dps = dtd_dtds2dps(dps, dtds, opt)
% function dps = dtd_dtds2dps(dps, dtds)

if nargin < 3
    opt = mdm_opt();
    opt = dtd_opt(opt);
end

%Per-voxel statistical measures
nn = size(dtds.w,4);

%Diffusion-weighted signals
dps.s0 = sum(dtds.w,4);
dps.s1000 = msf_notfinite2zero(sum(exp(-1e9*dtds.diso).*dtds.w,4));
dps.s2000 = msf_notfinite2zero(sum(exp(-2e9*dtds.diso).*dtds.w,4));
dps.s3000 = msf_notfinite2zero(sum(exp(-3e9*dtds.diso).*dtds.w,4));

%For comparison with EUSOBI consensus ADC, see https://doi.org/10.1007/s00330-019-06510-3
dps.s800 = msf_notfinite2zero(sum(exp(-0.8e9*dtds.diso).*dtds.w,4));
dps.adc800 = msf_notfinite2zero((log(dps.s0) - log(dps.s800))./ 0.8e9)/1e-9;

%Means
dps.mdiso = sum(dtds.diso.*dtds.w,4)./dps.s0;
dps.mdaniso = sum(dtds.daniso.*dtds.w,4)./dps.s0;
dps.msdaniso = sum(dtds.sdaniso.*dtds.w,4)./dps.s0;
dps.msddelta = sum(dtds.sddelta.*dtds.w,4)./dps.s0;
dps.mdxx = sum(dtds.dxx.*dtds.w,4)./dps.s0;
dps.mdyy = sum(dtds.dyy.*dtds.w,4)./dps.s0;
dps.mdzz = sum(dtds.dzz.*dtds.w,4)./dps.s0;
dps.mdxy = sum(dtds.dxy.*dtds.w,4)./dps.s0;
dps.mdxz = sum(dtds.dxz.*dtds.w,4)./dps.s0;
dps.mdyz = sum(dtds.dyz.*dtds.w,4)./dps.s0;

%Variances
dps.vdiso = sum((dtds.diso-repmat(dps.mdiso,[1 1 1 nn])).^2.*dtds.w,4)./dps.s0;
dps.vsdaniso = sum((dtds.sdaniso-repmat(dps.msdaniso,[1 1 1 nn])).^2.*dtds.w,4)./dps.s0;
dps.vsddelta = sum((dtds.sddelta-repmat(dps.msddelta,[1 1 1 nn])).^2.*dtds.w,4)./dps.s0;

%Covariances
dps.cvdisosdaniso = sum((dtds.diso-repmat(dps.mdiso,[1 1 1 nn])).*(dtds.sdaniso-repmat(dps.msdaniso,[1 1 1 nn])).*dtds.w,4)./dps.s0;
dps.cvdisosddelta = sum((dtds.diso-repmat(dps.mdiso,[1 1 1 nn])).*(dtds.sddelta-repmat(dps.msddelta,[1 1 1 nn])).*dtds.w,4)./dps.s0;

%Normalized measures
dps.nmdaniso = dps.mdaniso./dps.mdiso;
dps.nmsdaniso = dps.msdaniso./dps.mdiso.^2;
dps.nvdiso = dps.vdiso./dps.mdiso.^2;
dps.nvsdaniso = dps.vsdaniso./dps.msdaniso.^2;
dps.nvsddelta = dps.vsddelta./dps.msddelta.^2;


dps.Vl = 5/2 * 4/5*dps.msdaniso;
dps.MKi = 3 * dps.nvdiso; % Multiply by 3 to get kurtosis
dps.MKa = 3 * 4/5*dps.nmsdaniso;

% Calculate uFA. Take real component to avoid complex values due to
% sqrt of negative variances.
dps.ufa_old = real(sqrt(3/2) * sqrt(1./(dps.mdiso.^2./dps.Vl+1))); % Lasic (2014)
dps.ufa     = real(sqrt(3/2) * sqrt( dps.Vl ./ (dps.Vl + dps.vdiso + dps.mdiso.^2) )); % Szczepankiewicz (2016)

dps.signaniso = sign(dps.nmdaniso);

% clamp measures to avoid extreme values
if (opt.dtd.do_clamping)    
    dps.nmsdaniso    = mio_min_max_cut(dps.nmsdaniso, [0 1.5]);
    dps.nvdiso    = mio_min_max_cut(dps.nvdiso, [0 1]);    
end

% Standard voxel-average diffusion tensor parameters MD, FA, etc
sz_reshape  = msf_size(dps.s0, 3); % reshape help functions
g_reshape = @(a,n) reshape(a, prod(sz_reshape(1:3)), n);
f_reshape = @(a,n) reshape(a, sz_reshape(1), sz_reshape(2), sz_reshape(3), n);
dt_1x6 = cat(4,dps.mdxx,dps.mdyy,dps.mdzz,sqrt(2)*dps.mdxy,sqrt(2)*dps.mdxz,sqrt(2)*dps.mdyz); %Voigt format [xx, yy, zz, sqrt(2)*xy, sqrt(2)*xz, sqrt(2)*xz]
dps = tm_dt_to_dps(g_reshape(dt_1x6, 6)*1e9, dps, f_reshape, 0.0001);

