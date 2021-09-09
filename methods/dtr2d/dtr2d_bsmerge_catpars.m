function [dpar,dperp,theta,phi,r2,w] = dtr2d_bsmerge_catpars(dpar,dperp,theta,phi,r2,w,dpar_temp,dperp_temp,theta_temp,phi_temp,r2_temp,w_temp)

dpar = cat(4,dpar,dpar_temp);
dperp = cat(4,dperp,dperp_temp);
theta = cat(4,theta,theta_temp);
phi = cat(4,phi,phi_temp);
r2 = cat(4,r2,r2_temp);
w = cat(4,w,w_temp);
