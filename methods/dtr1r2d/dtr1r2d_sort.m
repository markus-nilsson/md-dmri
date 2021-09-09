function dtr1r2d_out = dtr1r2d_sort(dtr1r2d_in)

[n,par,perp,theta,phi,r1,r2,w] = dtr1r2d_dist2par(dtr1r2d_in);

[wsort,ind] = sort(w,'descend');
ind = ind(wsort>0);

n = numel(ind);
par = par(ind);
perp = perp(ind);
theta = theta(ind);
phi = phi(ind);
r1 = r1(ind);
r2 = r2(ind);
w = w(ind);

dtr1r2d_out = [par'; perp'; theta'; phi'; r1'; r2'; w'];
dtr1r2d_out = [n; dtr1r2d_out(:)];
