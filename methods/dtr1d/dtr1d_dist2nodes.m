function dtr1d_nodes = dtr1d_dist2nodes(dtr1d)

[n,par,perp,theta,phi,r1,w] = dtr1d_dist2par(dtr1d);

dtr1d_nodes = [par'; perp'; theta'; phi'; r1'];
dtr1d_nodes = [n; dtr1d_nodes(:)];
