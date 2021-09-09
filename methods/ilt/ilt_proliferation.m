function dtd = ilt_proliferation(stemp, b, b_delta, opt)

dmin = opt.ilt.dmin;
dmax = opt.ilt.dmax;
n_nodes = opt.ilt.n_in;
n_proliferation = opt.ilt.n_proliferation;

dtd_nodes1 = [];
for niter = 1:n_proliferation    
    dtd_nodes2 = ilt_rand(n_nodes,dmin,dmax);
    dtd_nodes = ilt_nodes_merge(dtd_nodes1,dtd_nodes2);

    dtd = ilt_data2dd(stemp, b, b_delta, dtd_nodes);    
    dtd_nodes1 = ilt_dist2nodes(dtd);
end

