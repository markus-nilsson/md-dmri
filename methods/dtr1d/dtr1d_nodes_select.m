function dtr1d_nodes_out = dtr1d_nodes_select(dtr1d_nodes,ind)

[n,par,perp,theta,phi,r1] = dtr1d_nodes2par(dtr1d_nodes);

n = numel(ind);
par = par(ind);
perp = perp(ind);
theta = theta(ind);
phi = phi(ind);
r1 = r1(ind);

dtr1d_nodes_out = [par'; perp'; theta'; phi'; r1'];
dtr1d_nodes_out = [n; dtr1d_nodes_out(:)];
