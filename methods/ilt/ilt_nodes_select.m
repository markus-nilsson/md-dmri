function dtd_nodes_out = ilt_nodes_select(dtd_nodes,ind)

[n,D] = ilt_nodes2par(dtd_nodes);

n = numel(ind);
D = D(ind);

dtd_nodes_out = [D'];
dtd_nodes_out = [n; dtd_nodes_out(:)];
