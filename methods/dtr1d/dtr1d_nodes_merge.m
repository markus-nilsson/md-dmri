function dtr1d_nodes = dtr1d_nodes_merge(dtr1d_nodes1,dtr1d_nodes2)

[n1,par1,perp1,theta1,phi1,r11] = dtr1d_nodes2par(dtr1d_nodes1);
[n2,par2,perp2,theta2,phi2,r12] = dtr1d_nodes2par(dtr1d_nodes2);

n = n1 + n2;
par = [par1; par2];
perp = [perp1; perp2];
theta = [theta1; theta2];
phi = [phi1; phi2];
r1 = [r11; r12];

dtr1d_nodes = [par'; perp'; theta'; phi'; r1'];
dtr1d_nodes = [n; dtr1d_nodes(:)];
