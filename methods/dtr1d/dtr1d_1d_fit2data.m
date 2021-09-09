function s = dtr1d_1d_fit2data(m, xps)

if m(1)>0
    dtr1d = dtr1d_m2dtr1d(m);
    [dtr1d_nx6,r1,w] = dtr1d_dist2nx6r1w(dtr1d);
    k = exp(-xps.bt*dtr1d_nx6').*(1-exp(-xps.tr*r1'));
    s = k*w;
else
    s = zeros(xps.n,1);
end

