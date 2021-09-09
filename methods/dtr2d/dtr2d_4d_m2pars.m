function [dpar,dperp,theta,phi,r2,w] = dtr2d_4d_m2pars(m)

sz = size(m);

ind = false(sz(4),1);
ind(2:6:end) = 1;

dpar = m(:,:,:,circshift(ind,0,1));
dperp = m(:,:,:,circshift(ind,1,1));
theta = m(:,:,:,circshift(ind,2,1));
phi = m(:,:,:,circshift(ind,3,1));
r2 = m(:,:,:,circshift(ind,4,1));
w = m(:,:,:,circshift(ind,5,1));
