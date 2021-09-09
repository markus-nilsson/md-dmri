function dtr1r2d = dtr1r2d_nodesw2dist(dtr1r2d_nodes,w)

[n,par,perp,theta,phi,r1,r2] = dtr1r2d_nodes2par(dtr1r2d_nodes);

dtr1r2d = [par'; perp'; theta'; phi'; r1'; r2'; w'];
dtr1r2d = [n; dtr1r2d(:)];
