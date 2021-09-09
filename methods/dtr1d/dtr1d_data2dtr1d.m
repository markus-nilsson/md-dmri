function dtr1d = dtr1d_data2dtr1d(stemp, bt_mx6, tr, dtr1d_nodes)

[dtr1d_nx6,r1] = dtr1d_nodes2nx6r1(dtr1d_nodes);

k = exp(-bt_mx6*dtr1d_nx6').*(1-exp(-tr*r1'));
snorm = max(stemp);
w = snorm*lsqnonneg(k,stemp/snorm);

dtr1d = dtr1d_nodesw2dist(dtr1d_nodes,w);
dtr1d = dtr1d_sort(dtr1d);




