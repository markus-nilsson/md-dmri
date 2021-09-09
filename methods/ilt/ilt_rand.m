function dtd_nodes = ilt_rand(n,dmin,dmax)

D = dmin*(dmax/dmin).^rand(1,n);

dtd_nodes = [D];
dtd_nodes = [n; dtd_nodes(:)];


