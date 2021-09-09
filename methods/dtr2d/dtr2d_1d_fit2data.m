function s = dtr2d_1d_fit2data(m, xps)

if m(1)>0
    dtr2d = dtr2d_m2dtr2d(m);
    [dtr2d_nx6,r2,w] = dtr2d_dist2nx6r2w(dtr2d);
    k = exp(-xps.bt*dtr2d_nx6').*exp(-xps.te*r2');
    s = k*w;
else
    s = zeros(xps.n,1);
end

