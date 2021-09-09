function [dpar,dperp,theta,phi,r1,w] = dtr1d_bsmerge_catpars(dpar,dperp,theta,phi,r1,w,dpar_temp,dperp_temp,theta_temp,phi_temp,r1_temp,w_temp)

dpar = cat(4,dpar,dpar_temp);
dperp = cat(4,dperp,dperp_temp);
theta = cat(4,theta,theta_temp);
phi = cat(4,phi,phi_temp);
r1 = cat(4,r1,r1_temp);
w = cat(4,w,w_temp);
