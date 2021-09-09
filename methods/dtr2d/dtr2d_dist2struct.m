function dtds = dtd_dist2struct(dtd)

[n,par,perp,theta,phi,w] = dtd_dist2par(dtd);

dtds = struct('n',n,'par',par,'perp',perp,'theta',theta,'phi',phi,'w',w);