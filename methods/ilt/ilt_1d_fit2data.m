function s = ilt_1d_fit2data(m, xps)
% function s = dtd_ndi_1d_fit2data(m, xps)

if m(1)>0
    dtd = ilt_m2dd(m);
    [~,D,w] = ilt_dist2par(dtd);
    k = exp(-xps.b*D');
    s = k*w;
else
    s = zeros(xps.n,1);
end

