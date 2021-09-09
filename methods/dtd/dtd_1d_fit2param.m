function dps = dtd_1d_fit2param(m)
% function dps = dtd_1d_fit2param(m)

mfs.m = zeros(1,1,1,numel(m)); mfs.m(1,1,1,:) = m;
dps = dtd_4d_fit2param(mfs.m);

