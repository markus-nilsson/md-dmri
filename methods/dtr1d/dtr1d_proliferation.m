function dtr1d = dtr1d_proliferation(stemp, bt_mx6, tr, opt)

dmin = opt.dtr1d.dmin;
dmax = opt.dtr1d.dmax;
r1min = opt.dtr1d.r1min;
r1max = opt.dtr1d.r1max;
n_nodes = opt.dtr1d.n_in;
n_proliferation = opt.dtr1d.n_proliferation;

dtr1d_nodes1 = [];
for niter = 1:n_proliferation    
    dtr1d_nodes2 = dtr1d_rand(n_nodes,dmin,dmax,r1min,r1max);
    dtr1d_nodes = dtr1d_nodes_merge(dtr1d_nodes1,dtr1d_nodes2);

    dtr1d = dtr1d_data2dtr1d(stemp,bt_mx6, tr, dtr1d_nodes);
    dtr1d_nodes1 = dtr1d_dist2nodes(dtr1d);
end

