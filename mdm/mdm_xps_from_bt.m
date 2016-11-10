function xps = mdm_xps_from_bt(bt)
% function xps = mdm_xps_from_bt(bt)

xps.n       = size(bt, 1);

xps.b       = zeros(xps.n, 1);
xps.b_delta = zeros(xps.n, 1);
xps.b_eta   = zeros(xps.n, 1);
xps.bt      = zeros(xps.n, 6);

for c = 1:size(bt, 1)
    
    tp = tm_3x3_to_tpars(tm_1x6_to_3x3(bt(c,:)));
    
    xps.b(c)        = tp.trace;
    xps.b_delta(c)  = tp.delta;
    xps.b_eta(c)    = tp.eta;
    xps.bt(c,:)     = bt(c,:);
    
end
