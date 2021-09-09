function dtr1d_out = dtr1d_sort(dtr1d_in)

[n,par,perp,theta,phi,r1,w] = dtr1d_dist2par(dtr1d_in);

[wsort,ind] = sort(w,'descend');
ind = ind(wsort>0);

n = numel(ind);
par = par(ind);
perp = perp(ind);
theta = theta(ind);
phi = phi(ind);
r1 = r1(ind);
w = w(ind);

dtr1d_out = [par'; perp'; theta'; phi'; r1'; w'];
dtr1d_out = [n; dtr1d_out(:)];
