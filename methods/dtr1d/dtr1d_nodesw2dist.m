function dtr1d = dtr1d_nodesw2dist(dtr1d_nodes,w)

[n,par,perp,theta,phi,r1] = dtr1d_nodes2par(dtr1d_nodes);

dtr1d = [par'; perp'; theta'; phi'; r1'; w'];
dtr1d = [n; dtr1d(:)];
