function c = dist_cind2rgb_jet(cind)

cind(cind<0) = 0;
cind(cind>1) = 1;

c.r = -1 + 3*cind;
c.r(c.r<0) = 0;
c.r(c.r>1) = 1;
c.r(~isfinite(c.r)) = 0;

c.g =  1.5 - 3*abs(cind-.5);
c.g(c.g<0) = 0;
c.g(c.g>1) = 1;
c.g(~isfinite(c.g)) = 0;

c.b =  2 - 3*cind;
c.b(c.b<0) = 0;
c.b(c.b>1) = 1;
c.b(~isfinite(c.b)) = 0;

