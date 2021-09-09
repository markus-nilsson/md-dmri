function dtr2d_nodes = dtr2d_nodes_merge(dtr2d_nodes1,dtr2d_nodes2)

[n1,par1,perp1,theta1,phi1,r21] = dtr2d_nodes2par(dtr2d_nodes1);
[n2,par2,perp2,theta2,phi2,r22] = dtr2d_nodes2par(dtr2d_nodes2);

n = n1 + n2;
par = [par1; par2];
perp = [perp1; perp2];
theta = [theta1; theta2];
phi = [phi1; phi2];
r2 = [r21; r22];

dtr2d_nodes = [par'; perp'; theta'; phi'; r2'];
dtr2d_nodes = [n; dtr2d_nodes(:)];
