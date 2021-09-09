function dtr1d = dtr1d_extinction(stemp, bt_mx6, tr, dtr1d, opt)

n_nodes = opt.dtr1d.n_in;
n_extinction = opt.dtr1d.n_extinction;

for niter = 1:n_extinction    
    n_in = dtr1d(1);
    n_max = min([(n_in-opt.dtr1d.n_kill) opt.dtr1d.n_out dtr1d(1)]);

    dtr1d_nodes1 = dtr1d_dist2nodes(dtr1d);
    ind = 1:n_max;
    dtr1d_nodes1 = dtr1d_nodes_select(dtr1d_nodes1,ind);
    ind = 1 + floor((n_max-1)*linspace(0,1,n_nodes).^3);
    ind(ind<1) = 1;
    %dtr1d_nodes1(1)
    %ind
    if dtr1d_nodes1(1) == 0
        dtr1d = [];
        break
    end
    
    dtr1d_nodes2 = dtr1d_nodes_select(dtr1d_nodes1,ind);
    dtr1d_nodes2 = dtr1d_nodes_mutate(dtr1d_nodes2,opt);

    dtr1d_nodes = dtr1d_nodes_merge(dtr1d_nodes1,dtr1d_nodes2);

    dtr1d = dtr1d_data2dtr1d(stemp,bt_mx6,tr,dtr1d_nodes);    
end

if ~isempty(dtr1d)
    dtr1d_nodes = dtr1d_dist2nodes(dtr1d);
    n_max = min([opt.dtr1d.n_out dtr1d(1)]);
    ind = 1:n_max;
    dtr1d_nodes = dtr1d_nodes_select(dtr1d_nodes,ind);
    dtr1d = dtr1d_data2dtr1d(stemp,bt_mx6,tr,dtr1d_nodes);    
end
