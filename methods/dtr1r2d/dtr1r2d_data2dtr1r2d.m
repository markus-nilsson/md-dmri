function dtr1r2d = dtr1r2d_data2dtr1r2d(stemp, bt_mx6, tr, te, dtr1r2d_nodes)

[dtr1r2d_nx6,r1,r2] = dtr1r2d_nodes2nx6r1r2(dtr1r2d_nodes);

k = exp(-bt_mx6*dtr1r2d_nx6').*(1-exp(-tr*r1')).*exp(-te*r2');
snorm = max(stemp);
w = snorm*lsqnonneg(k,stemp/snorm);

dtr1r2d = dtr1r2d_nodesw2dist(dtr1r2d_nodes,w);
dtr1r2d = dtr1r2d_sort(dtr1r2d);




