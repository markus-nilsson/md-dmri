function nodes4d = dtr1d_4d_m2nodes(mfs_fn, opt)
% function mfs = dtr1d_4d_m2nodes(mfs_fn, mfs_fn, opt)

if (nargin < 2), mfs_fn = []; end
if (nargin < 3), opt = []; end

opt = mdm_opt(opt);
opt = dtr1d_opt(opt);

mfs = mdm_mfs_load(mfs_fn);

m4d = mfs.m;
sz = size(m4d);
M = mfs.mask;
nodes4d = zeros(sz(1),sz(2),sz(3),(1+opt.dtr1d.n_out*7*5));

for nk = 1:sz(3)
    for nj = 1:sz(2)
        for ni = 1:sz(1)
            %ni = 30; nj = 30; nk = 8;
            if M(ni,nj,nk)
                m = squeeze(m4d(ni,nj,nk,:))';
                dtr1d = dtr1d_m2dtr1d(m);
                dtr1d_nodes000 = dtr1d_dist2nodes(dtr1d);
                m = squeeze(m4d(max([ni-1 1]),nj,nk,:))';
                dtr1d = dtr1d_m2dtr1d(m);
                dtr1d_nodesm00 = dtr1d_dist2nodes(dtr1d);
                m = squeeze(m4d(ni,max([nj-1 1]),nk,:))';
                dtr1d = dtr1d_m2dtr1d(m);
                dtr1d_nodes0m0 = dtr1d_dist2nodes(dtr1d);
                m = squeeze(m4d(ni,nj,max([nk-1 1]),:))';
                dtr1d = dtr1d_m2dtr1d(m);
                dtr1d_nodes00m = dtr1d_dist2nodes(dtr1d);
                m = squeeze(m4d(min([ni+1 sz(1)]),nj,nk,:))';
                dtr1d = dtr1d_m2dtr1d(m);
                dtr1d_nodesp00 = dtr1d_dist2nodes(dtr1d);
                m = squeeze(m4d(ni,min([nj+1 sz(2)]),nk,:))';
                dtr1d = dtr1d_m2dtr1d(m);
                dtr1d_nodes0p0 = dtr1d_dist2nodes(dtr1d);
                m = squeeze(m4d(ni,nj,min([nk+1 sz(3)]),:))';
                dtr1d = dtr1d_m2dtr1d(m);
                dtr1d_nodes00p = dtr1d_dist2nodes(dtr1d);
                
                dtr1d_nodes = dtr1d_nodes_merge(dtr1d_nodes000,dtr1d_nodesm00);
                dtr1d_nodes = dtr1d_nodes_merge(dtr1d_nodes,dtr1d_nodes0m0);
                dtr1d_nodes = dtr1d_nodes_merge(dtr1d_nodes,dtr1d_nodes00m);
                dtr1d_nodes = dtr1d_nodes_merge(dtr1d_nodes,dtr1d_nodesp00);
                dtr1d_nodes = dtr1d_nodes_merge(dtr1d_nodes,dtr1d_nodes0p0);
                dtr1d_nodes = dtr1d_nodes_merge(dtr1d_nodes,dtr1d_nodes00p);
                
                nodes4d(ni,nj,nk,1:numel(dtr1d_nodes)) = dtr1d_nodes;
                                
%                 figure(1), clf
%                 [n,par,perp,theta,phi,r1] = dtr1d_nodes2par(dtr1d_nodes);
%                 plot(log10(par),log10(perp),'bo','MarkerSize',5)
%                 hold on
%                 [n,par,perp,theta,phi,r2] = dtr1d_nodes2par(dtr1d_nodes000);
%                 plot(log10(par),log10(perp),'ko','MarkerSize',10)
%                 axis('equal')
%                 title([num2str(ni) ' ' num2str(nj) ' ' num2str(nk)])
%                 pause(.05)
            end
        end
    end
end





