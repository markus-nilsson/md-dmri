function dps = dtr1r2d_dtr1r2ds2dps(dps, dtr1r2ds)
% function dps = dtr1r2d_dtr1r2ds2dps(dps, dtr1r2ds)

%Per-voxel statistical measures
nn = size(dtr1r2ds.w,4);

%DTD parameters
dps = dtd_dtds2dps(dps, dtr1r2ds);

%Means
dps.mr1 = msf_notfinite2zero(sum(dtr1r2ds.r1.*dtr1r2ds.w,4)./dps.s0);
dps.mr2 = msf_notfinite2zero(sum(dtr1r2ds.r2.*dtr1r2ds.w,4)./dps.s0);

%Variances
dps.vr1 = msf_notfinite2zero(sum((dtr1r2ds.r1-repmat(dps.mr1,[1 1 1 nn])).^2.*dtr1r2ds.w,4)./dps.s0);
dps.vr2 = msf_notfinite2zero(sum((dtr1r2ds.r2-repmat(dps.mr2,[1 1 1 nn])).^2.*dtr1r2ds.w,4)./dps.s0);

%Covariances
dps.cvdisor1 = msf_notfinite2zero(sum((dtr1r2ds.diso-repmat(dps.mdiso,[1 1 1 nn])).*(dtr1r2ds.r1-repmat(dps.mr1,[1 1 1 nn])).*dtr1r2ds.w,4)./dps.s0);
dps.cvsddeltar1 = msf_notfinite2zero(sum((dtr1r2ds.r1-repmat(dps.mr1,[1 1 1 nn])).*(dtr1r2ds.sddelta-repmat(dps.msddelta,[1 1 1 nn])).*dtr1r2ds.w,4)./dps.s0);
dps.cvdisor2 = msf_notfinite2zero(sum((dtr1r2ds.diso-repmat(dps.mdiso,[1 1 1 nn])).*(dtr1r2ds.r2-repmat(dps.mr2,[1 1 1 nn])).*dtr1r2ds.w,4)./dps.s0);
dps.cvsddeltar2 = msf_notfinite2zero(sum((dtr1r2ds.r1-repmat(dps.mr2,[1 1 1 nn])).*(dtr1r2ds.sddelta-repmat(dps.msddelta,[1 1 1 nn])).*dtr1r2ds.w,4)./dps.s0);
dps.cvr1r2 = msf_notfinite2zero(sum((dtr1r2ds.r1-repmat(dps.mr1,[1 1 1 nn])).*(dtr1r2ds.r2-repmat(dps.mr2,[1 1 1 nn])).*dtr1r2ds.w,4)./dps.s0);

%Normalized measures
dps.nvr1 = msf_notfinite2zero(dps.vr1./dps.mr1.^2);
dps.nvr2 = msf_notfinite2zero(dps.vr2./dps.mr2.^2);
