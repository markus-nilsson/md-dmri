function dtr2d_nodes = dtr2d_dist2nodes(dtr2d)

[n,par,perp,theta,phi,r2,w] = dtr2d_dist2par(dtr2d);

dtr2d_nodes = [par'; perp'; theta'; phi'; r2'];
dtr2d_nodes = [n; dtr2d_nodes(:)];
