function dtd = ilt_extinction(stemp, b, b_delta, dtd, opt)
% function dtd = dtd_pa_extinction(stemp, b, b_delta, dtd, opt)

n_nodes         = opt.ilt.n_in;
n_extinction    = opt.ilt.n_extinction;
n_kill          = opt.ilt.n_kill;
n_out           = opt.ilt.n_out;

for niter = 1:n_extinction    
    
    n_in = dtd(1);
    n_max = min([(n_in-n_kill) n_out dtd(1)]);

    dtd_nodes1 = ilt_dist2nodes(dtd);
    ind = 1:n_max;
    dtd_nodes1 = ilt_nodes_select(dtd_nodes1,ind);
    ind = 1 + floor((n_max-1)*linspace(0,1,n_nodes).^3);
    ind(ind<1) = 1;
    
    if dtd_nodes1(1) == 0
        dtd = [];
        break
    end
    
    dtd_nodes2 = ilt_nodes_select(dtd_nodes1,ind);
    dtd_nodes2 = ilt_nodes_mutate(dtd_nodes2,opt);

    dtd_nodes = ilt_nodes_merge(dtd_nodes1,dtd_nodes2);

    dtd = ilt_data2dd(stemp, b, b_delta, dtd_nodes);
end

if ~isempty(dtd)
    dtd_nodes = ilt_dist2nodes(dtd);
    n_max = min([n_out dtd(1)]);
    ind = 1:n_max;
    dtd_nodes = ilt_nodes_select(dtd_nodes,ind);
    dtd = ilt_data2dd(stemp, b, b_delta, dtd_nodes);   
end
