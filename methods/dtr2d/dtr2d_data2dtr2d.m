function dtr2d = dtr2d_data2dtr2d(stemp, bt_mx6, te, dtr2d_nodes)

[dtr2d_nx6,r2] = dtr2d_nodes2nx6r2(dtr2d_nodes);

k = exp(-bt_mx6*dtr2d_nx6').*exp(-te*r2');
snorm = max(stemp);
w = snorm*lsqnonneg(k,stemp/snorm);

dtr2d = dtr2d_nodesw2dist(dtr2d_nodes,w);
dtr2d = dtr2d_sort(dtr2d);




