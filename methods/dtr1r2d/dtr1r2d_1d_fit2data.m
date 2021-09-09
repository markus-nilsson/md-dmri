function s = dtr1r2d_1d_fit2data(m, xps)

if m(1)>0
    dtr1r2d = dtr1r2d_m2dtr1r2d(m);
    [dtr1r2d_nx6,r1,r2,w] = dtr1r2d_dist2nx6r1r2w(dtr1r2d);
    k = exp(-xps.bt*dtr1r2d_nx6').*(1-exp(-xps.tr*r1')).*exp(-xps.te*r2');
    s = k*w;
else
    s = zeros(xps.n,1);
end

