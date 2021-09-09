function dtr1r2d_nodes = dtr1r2d_dist2nodes(dtr1r2d)

[n,par,perp,theta,phi,r1,r2,w] = dtr1r2d_dist2par(dtr1r2d);

dtr1r2d_nodes = [par'; perp'; theta'; phi'; r1'; r2'];
dtr1r2d_nodes = [n; dtr1r2d_nodes(:)];
