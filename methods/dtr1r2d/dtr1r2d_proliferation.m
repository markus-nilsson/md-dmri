function dtr1r2d = dtr1r2d_proliferation(stemp, bt_mx6, tr, te, opt)

dmin = opt.dtr1r2d.dmin;
dmax = opt.dtr1r2d.dmax;
r1min = opt.dtr1r2d.r1min;
r1max = opt.dtr1r2d.r1max;
r2min = opt.dtr1r2d.r2min;
r2max = opt.dtr1r2d.r2max;
n_nodes = opt.dtr1r2d.n_in;
n_proliferation = opt.dtr1r2d.n_proliferation;

dtr1r2d_nodes1 = [];
for niter = 1:n_proliferation    
    dtr1r2d_nodes2 = dtr1r2d_rand(n_nodes,dmin,dmax,r1min,r1max,r2min,r2max);
    dtr1r2d_nodes = dtr1r2d_nodes_merge(dtr1r2d_nodes1,dtr1r2d_nodes2);

    dtr1r2d = dtr1r2d_data2dtr1r2d(stemp,bt_mx6, tr, te, dtr1r2d_nodes);
    dtr1r2d_nodes1 = dtr1r2d_dist2nodes(dtr1r2d);
end

