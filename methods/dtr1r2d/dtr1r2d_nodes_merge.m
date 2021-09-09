function dtr1r2d_nodes = dtr1r2d_nodes_merge(dtr1r2d_nodes1,dtr1r2d_nodes2)

[n1,par1,perp1,theta1,phi1,r11,r21] = dtr1r2d_nodes2par(dtr1r2d_nodes1);
[n2,par2,perp2,theta2,phi2,r12,r22] = dtr1r2d_nodes2par(dtr1r2d_nodes2);

n = n1 + n2;
par = [par1; par2];
perp = [perp1; perp2];
theta = [theta1; theta2];
phi = [phi1; phi2];
r1 = [r11; r12];
r2 = [r21; r22];

dtr1r2d_nodes = [par'; perp'; theta'; phi'; r1'; r2'];
dtr1r2d_nodes = [n; dtr1r2d_nodes(:)];
