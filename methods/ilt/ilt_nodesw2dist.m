function dtd = ilt_nodesw2dist(dtd_nodes,w)

[n,D] = ilt_nodes2par(dtd_nodes);

dtd = [D'; w'];
dtd = [n; dtd(:)];
