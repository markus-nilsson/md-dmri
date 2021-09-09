function [diso,daniso,dratio,ddelta,sdaniso,sddelta] = dtd_pars2dpars(dpar,dperp)

diso = (dpar + 2*dperp)/3;
daniso = (dpar - dperp)/3;
dratio = msf_notfinite2zero(dpar./dperp);
ddelta = msf_notfinite2zero(daniso./diso);
sdaniso = daniso.^2;
sddelta = msf_notfinite2zero(sdaniso./diso.^2);
