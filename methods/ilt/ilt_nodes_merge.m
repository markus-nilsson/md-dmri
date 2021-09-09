function dtd_nodes = ilt_nodes_merge(dtd_nodes1,dtd_nodes2)

[n1,D1] = ilt_nodes2par(dtd_nodes1);
[n2,D2] = ilt_nodes2par(dtd_nodes2);

n = n1 + n2;
D = [D1; D2];

dtd_nodes = [D'];
dtd_nodes = [n; dtd_nodes(:)];
