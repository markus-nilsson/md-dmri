function dtr1r2d = dtr1r2d_extinction(stemp, bt_mx6, tr, te, dtr1r2d, opt)

n_nodes = opt.dtr1r2d.n_in;
n_extinction = opt.dtr1r2d.n_extinction;

for niter = 1:n_extinction    
    n_in = dtr1r2d(1);
    n_max = min([(n_in-opt.dtr1r2d.n_kill) opt.dtr1r2d.n_out dtr1r2d(1)]);

    dtr1r2d_nodes1 = dtr1r2d_dist2nodes(dtr1r2d);
    ind = 1:n_max;
    dtr1r2d_nodes1 = dtr1r2d_nodes_select(dtr1r2d_nodes1,ind);
    ind = 1 + floor((n_max-1)*linspace(0,1,n_nodes).^3);
    ind(ind<1) = 1;
    %dtr1r2d_nodes1(1)
    %ind
    if dtr1r2d_nodes1(1) == 0
        dtr1r2d = [];
        break
    end
    
    dtr1r2d_nodes2 = dtr1r2d_nodes_select(dtr1r2d_nodes1,ind);
    dtr1r2d_nodes2 = dtr1r2d_nodes_mutate(dtr1r2d_nodes2,opt);

    dtr1r2d_nodes = dtr1r2d_nodes_merge(dtr1r2d_nodes1,dtr1r2d_nodes2);

    dtr1r2d = dtr1r2d_data2dtr1r2d(stemp,bt_mx6,tr,te,dtr1r2d_nodes);    
end

if ~isempty(dtr1r2d)
    dtr1r2d_nodes = dtr1r2d_dist2nodes(dtr1r2d);
    n_max = min([opt.dtr1r2d.n_out dtr1r2d(1)]);
    ind = 1:n_max;
    dtr1r2d_nodes = dtr1r2d_nodes_select(dtr1r2d_nodes,ind);
    dtr1r2d = dtr1r2d_data2dtr1r2d(stemp,bt_mx6,tr,te,dtr1r2d_nodes);    
end
