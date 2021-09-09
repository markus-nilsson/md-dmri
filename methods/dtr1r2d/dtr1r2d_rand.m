function dtr1r2d_nodes = dtr1r2d_rand(n,dmin,dmax,r1min,r1max,r2min,r2max)

par = dmin*(dmax/dmin).^rand(1,n);
perp = dmin*(dmax/dmin).^rand(1,n);
theta = acos(2*rand(1,n)-1);
phi = 2*pi*rand(1,n);
r1 = r1min*(r1max/r1min).^rand(1,n);
r2 = r2min*(r2max/r2min).^rand(1,n);

dtr1r2d_nodes = [par; perp; theta; phi; r1; r2];
dtr1r2d_nodes = [n; dtr1r2d_nodes(:)];


