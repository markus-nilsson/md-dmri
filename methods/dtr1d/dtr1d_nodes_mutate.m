function dtr1d_nodes_out = dtr1d_mutate(dtr1d_nodes,opt)

[n,par,perp,theta,phi,r1] = dtr1d_nodes2par(dtr1d_nodes);

par = par.*(1+opt.dtr1d.dfuzz*randn(n,1));
perp = perp.*(1+opt.dtr1d.dfuzz*randn(n,1));
theta = theta + opt.dtr1d.ofuzz*randn(n,1);
phi = phi + opt.dtr1d.ofuzz*randn(n,1);
r1 = r1.*(1+opt.dtr1d.r1fuzz*randn(n,1));

par(par>opt.dtr1d.dmax) = opt.dtr1d.dmax;
perp(perp>opt.dtr1d.dmax) = opt.dtr1d.dmax;
r1(r1>opt.dtr1d.r1max) = opt.dtr1d.r1max;
par(par<opt.dtr1d.dmin) = opt.dtr1d.dmin;
perp(perp<opt.dtr1d.dmin) = opt.dtr1d.dmin;
r1(r1<opt.dtr1d.r1min) = opt.dtr1d.r1min;

dtr1d_nodes_out = [par'; perp'; theta'; phi'; r1'];
dtr1d_nodes_out = [n; dtr1d_nodes_out(:)];
