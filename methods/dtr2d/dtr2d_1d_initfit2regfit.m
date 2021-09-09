function m = dtr2d_1d_initfit2regfit(signal, xps, opt, ind, dtr2d_nodes)
% function m = dtr2d_1d_initfit2regfit(signal, xps, opt, ind)
%
% Size-shape-orientation diffusion tensor distribution

if (nargin < 4), ind = ones(size(signal)) > 0; end

bt_mx6 = xps.bt(find(ind),:);
te = xps.te(ind);
stemp = signal(ind);

if dtr2d_nodes(1)>1
    dtr2d_nodes = dtr2d_nodes(1:(1+5*dtr2d_nodes(1)));
    dtr2d = dtr2d_data2dtr2d(stemp,bt_mx6,te,dtr2d_nodes);
else
    dtr2d = [];
end
if ~isempty(dtr2d)
    if dtr2d(1) > 0
        dtr2d_nodes = dtr2d_dist2nodes(dtr2d);
        n_max = min([opt.dtr2d.n_out dtr2d(1)]);
        dtr2d_nodes = dtr2d_nodes_select(dtr2d_nodes,1:n_max);
        dtr2d = dtr2d_data2dtr2d(stemp,bt_mx6,te,dtr2d_nodes); 
    end
end

m = dtr2d_dtr2d2m(dtr2d,opt);
%size(m), pause
if (opt.dtr2d.do_plot)
    figure(1), clf
    signal_fit = dtr2d_1d_fit2data(m, xps);
    %[~,s_ind] = sort(signal_fit,'descend');
    %semilogy(xps.b,signal,'.',xps.b,signal_fit,'o',xps.b,m(1)*weight,'x');
    plot(1:xps.n,signal,'o',1:xps.n,signal_fit,'x');
    %set(gca,'YLim',m(1)*[.01 1.2])
    pause(0.05);
end