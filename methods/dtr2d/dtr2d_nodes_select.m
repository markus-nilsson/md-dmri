function dtr2d_nodes_out = dtr2d_nodes_select(dtr2d_nodes,ind)

[n,par,perp,theta,phi,r2] = dtr2d_nodes2par(dtr2d_nodes);

n = numel(ind);
par = par(ind);
perp = perp(ind);
theta = theta(ind);
phi = phi(ind);
r2 = r2(ind);

dtr2d_nodes_out = [par'; perp'; theta'; phi'; r2'];
dtr2d_nodes_out = [n; dtr2d_nodes_out(:)];
