function dtr1r2d_nodes_out = dtr1r2d_nodes_select(dtr1r2d_nodes,ind)

[n,par,perp,theta,phi,r1,r2] = dtr1r2d_nodes2par(dtr1r2d_nodes);

n = numel(ind);
par = par(ind);
perp = perp(ind);
theta = theta(ind);
phi = phi(ind);
r1 = r1(ind);
r2 = r2(ind);

dtr1r2d_nodes_out = [par'; perp'; theta'; phi'; r1'; r2'];
dtr1r2d_nodes_out = [n; dtr1r2d_nodes_out(:)];
