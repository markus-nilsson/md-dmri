function dtr2d_nodes_out = dtr2d_mutate(dtr2d_nodes,opt)

[n,par,perp,theta,phi,r2] = dtr2d_nodes2par(dtr2d_nodes);

par = par.*(1+opt.dtr2d.dfuzz*randn(n,1));
perp = perp.*(1+opt.dtr2d.dfuzz*randn(n,1));
theta = theta + opt.dtr2d.ofuzz*randn(n,1);
phi = phi + opt.dtr2d.ofuzz*randn(n,1);
r2 = r2.*(1+opt.dtr2d.r2fuzz*randn(n,1));

par(par>opt.dtr2d.dmax) = opt.dtr2d.dmax;
perp(perp>opt.dtr2d.dmax) = opt.dtr2d.dmax;
r2(r2>opt.dtr2d.r2max) = opt.dtr2d.r2max;
par(par<opt.dtr2d.dmin) = opt.dtr2d.dmin;
perp(perp<opt.dtr2d.dmin) = opt.dtr2d.dmin;
r2(r2<opt.dtr2d.r2min) = opt.dtr2d.r2min;

dtr2d_nodes_out = [par'; perp'; theta'; phi'; r2'];
dtr2d_nodes_out = [n; dtr2d_nodes_out(:)];
