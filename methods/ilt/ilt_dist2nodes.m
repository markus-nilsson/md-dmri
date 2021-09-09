function dtd_nodes = ilt_dist2nodes(dtd)

[n,D,w] = ilt_dist2par(dtd);

dtd_nodes = [D'];
dtd_nodes = [n; dtd_nodes(:)];
