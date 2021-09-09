function dtd = ilt_data2dd(stemp,b,b_delta,dtd_nodes)

[~,D] = ilt_nodes2par(dtd_nodes);

bd = b*D';
k = exp(-bd);

k(bd == 0) = 1;
k(isnan(k)) = 0;
k(isinf(k)) = 0;

snorm = max(stemp);
w = snorm*lsqnonneg(k,stemp/snorm);

dtd = ilt_nodesw2dist(dtd_nodes,w);
dtd = ilt_sort(dtd);
