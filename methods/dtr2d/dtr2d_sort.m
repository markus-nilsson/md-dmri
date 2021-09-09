function dtr2d_out = dtr2d_sort(dtr2d_in)

[n,par,perp,theta,phi,r2,w] = dtr2d_dist2par(dtr2d_in);

[wsort,ind] = sort(w,'descend');
ind = ind(wsort>0);

n = numel(ind);
par = par(ind);
perp = perp(ind);
theta = theta(ind);
phi = phi(ind);
r2 = r2(ind);
w = w(ind);

dtr2d_out = [par'; perp'; theta'; phi'; r2'; w'];
dtr2d_out = [n; dtr2d_out(:)];
