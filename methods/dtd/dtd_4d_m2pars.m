function [dpar,dperp,theta,phi,w] = dtd_4d_m2pars(m)

sz = size(m);

ind = false(sz(4),1);
ind(2:5:end) = 1;

dpar = m(:,:,:,circshift(ind,0,1));
dperp = m(:,:,:,circshift(ind,1,1));
theta = m(:,:,:,circshift(ind,2,1));
phi = m(:,:,:,circshift(ind,3,1));
w = m(:,:,:,circshift(ind,4,1));
