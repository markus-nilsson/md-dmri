function dps = dtr1d_dtr1ds2dps(dps, dtr1ds)
% function dps = dtr1d_dtr1ds2dps(dps, dtr1ds)

%Per-voxel statistical measures
nn = size(dtr1ds.w,4);

%DTD parameters
dps = dtd_dtds2dps(dps, dtr1ds);

%Means
dps.mr1 = msf_notfinite2zero(sum(dtr1ds.r1.*dtr1ds.w,4)./dps.s0);

%Variances
dps.vr1 = msf_notfinite2zero(sum((dtr1ds.r1-repmat(dps.mr1,[1 1 1 nn])).^2.*dtr1ds.w,4)./dps.s0);

%Covariances
dps.cvdisor1 = msf_notfinite2zero(sum((dtr1ds.diso-repmat(dps.mdiso,[1 1 1 nn])).*(dtr1ds.r1-repmat(dps.mr1,[1 1 1 nn])).*dtr1ds.w,4)./dps.s0);
dps.cvsddeltar1 = msf_notfinite2zero(sum((dtr1ds.r1-repmat(dps.mr1,[1 1 1 nn])).*(dtr1ds.sddelta-repmat(dps.msddelta,[1 1 1 nn])).*dtr1ds.w,4)./dps.s0);

%Normalized measures
dps.nvr1 = msf_notfinite2zero(dps.vr1./dps.mr1.^2);
