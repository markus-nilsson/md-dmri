function dtr2d = dtr2d_proliferation(stemp, bt_mx6, te, opt)

dmin = opt.dtr2d.dmin;
dmax = opt.dtr2d.dmax;
r2min = opt.dtr2d.r2min;
r2max = opt.dtr2d.r2max;
n_nodes = opt.dtr2d.n_in;
n_proliferation = opt.dtr2d.n_proliferation;

dtr2d_nodes1 = [];
for niter = 1:n_proliferation    
    dtr2d_nodes2 = dtr2d_rand(n_nodes,dmin,dmax,r2min,r2max);
    dtr2d_nodes = dtr2d_nodes_merge(dtr2d_nodes1,dtr2d_nodes2);

    dtr2d = dtr2d_data2dtr2d(stemp,bt_mx6, te, dtr2d_nodes);
    dtr2d_nodes1 = dtr2d_dist2nodes(dtr2d);
end

