function dps = dtr2d_dtr2ds2dps(dps, dtr2ds)
% function dps = dtr2d_dtr2ds2dps(dps, dtr2ds)

%Per-voxel statistical measures
nn = size(dtr2ds.w,4);

%DTD parameters
dps = dtd_dtds2dps(dps, dtr2ds);

%Means
dps.mr2 = msf_notfinite2zero(sum(dtr2ds.r2.*dtr2ds.w,4)./dps.s0);

%Variances
dps.vr2 = msf_notfinite2zero(sum((dtr2ds.r2-repmat(dps.mr2,[1 1 1 nn])).^2.*dtr2ds.w,4)./dps.s0);

%Covariances
dps.cvdisor2 = msf_notfinite2zero(sum((dtr2ds.diso-repmat(dps.mdiso,[1 1 1 nn])).*(dtr2ds.r2-repmat(dps.mr2,[1 1 1 nn])).*dtr2ds.w,4)./dps.s0);
dps.cvsddeltar2 = msf_notfinite2zero(sum((dtr2ds.r2-repmat(dps.mr2,[1 1 1 nn])).*(dtr2ds.sddelta-repmat(dps.msddelta,[1 1 1 nn])).*dtr2ds.w,4)./dps.s0);

%Normalized measures
dps.nvr2 = msf_notfinite2zero(dps.vr2./dps.mr2.^2);
