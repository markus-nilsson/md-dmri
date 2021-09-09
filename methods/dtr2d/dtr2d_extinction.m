function dtr2d = dtr2d_extinction(stemp, bt_mx6, te, dtr2d, opt)

n_nodes = opt.dtr2d.n_in;
n_extinction = opt.dtr2d.n_extinction;

for niter = 1:n_extinction    
    n_in = dtr2d(1);
    n_max = min([(n_in-opt.dtr2d.n_kill) opt.dtr2d.n_out dtr2d(1)]);

    dtr2d_nodes1 = dtr2d_dist2nodes(dtr2d);
    ind = 1:n_max;
    dtr2d_nodes1 = dtr2d_nodes_select(dtr2d_nodes1,ind);
    ind = 1 + floor((n_max-1)*linspace(0,1,n_nodes).^3);
    ind(ind<1) = 1;
    %dtr2d_nodes1(1)
    %ind
    if dtr2d_nodes1(1) == 0
        dtr2d = [];
        break
    end
    
    dtr2d_nodes2 = dtr2d_nodes_select(dtr2d_nodes1,ind);
    dtr2d_nodes2 = dtr2d_nodes_mutate(dtr2d_nodes2,opt);

    dtr2d_nodes = dtr2d_nodes_merge(dtr2d_nodes1,dtr2d_nodes2);

    dtr2d = dtr2d_data2dtr2d(stemp,bt_mx6,te,dtr2d_nodes);    
end

if ~isempty(dtr2d)
    dtr2d_nodes = dtr2d_dist2nodes(dtr2d);
    n_max = min([opt.dtr2d.n_out dtr2d(1)]);
    ind = 1:n_max;
    dtr2d_nodes = dtr2d_nodes_select(dtr2d_nodes,ind);
    dtr2d = dtr2d_data2dtr2d(stemp,bt_mx6,te,dtr2d_nodes);    
end
