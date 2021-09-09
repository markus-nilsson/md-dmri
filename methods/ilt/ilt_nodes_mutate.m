function dtd_nodes_out = ilt_nodes_mutate(dtd_nodes,opt)

[n,D] = ilt_nodes2par(dtd_nodes);

D = D.*(1+opt.ilt.dfuzz*randn(n,1));

D(D>opt.ilt.dmax) = opt.ilt.dmax;
D(D<opt.ilt.dmin) = opt.ilt.dmin;

dtd_nodes_out = [D'];
dtd_nodes_out = [n; dtd_nodes_out(:)];
