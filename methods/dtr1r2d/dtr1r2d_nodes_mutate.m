function dtr1r2d_nodes_out = dtr1r2d_mutate(dtr1r2d_nodes,opt)

[n,par,perp,theta,phi,r1,r2] = dtr1r2d_nodes2par(dtr1r2d_nodes);

par = par.*(1+opt.dtr1r2d.dfuzz*randn(n,1));
perp = perp.*(1+opt.dtr1r2d.dfuzz*randn(n,1));
theta = theta + opt.dtr1r2d.ofuzz*randn(n,1);
phi = phi + opt.dtr1r2d.ofuzz*randn(n,1);
r1 = r1.*(1+opt.dtr1r2d.r1fuzz*randn(n,1));
r2 = r2.*(1+opt.dtr1r2d.r2fuzz*randn(n,1));

par(par>opt.dtr1r2d.dmax) = opt.dtr1r2d.dmax;
perp(perp>opt.dtr1r2d.dmax) = opt.dtr1r2d.dmax;
r1(r1>opt.dtr1r2d.r1max) = opt.dtr1r2d.r1max;
r2(r2>opt.dtr1r2d.r2max) = opt.dtr1r2d.r2max;
par(par<opt.dtr1r2d.dmin) = opt.dtr1r2d.dmin;
perp(perp<opt.dtr1r2d.dmin) = opt.dtr1r2d.dmin;
r1(r1<opt.dtr1r2d.r1min) = opt.dtr1r2d.r1min;
r2(r2<opt.dtr1r2d.r2min) = opt.dtr1r2d.r2min;

dtr1r2d_nodes_out = [par'; perp'; theta'; phi'; r1'; r2'];
dtr1r2d_nodes_out = [n; dtr1r2d_nodes_out(:)];
