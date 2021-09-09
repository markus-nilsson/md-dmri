function dtr1d = dtr1d_par1dist(par,perp,theta,phi,r1,w)

n = numel(par);

if n>0
    dtr1d = [par'; perp'; theta'; phi'; r1'; w'];
    dtr1d = [n; dtr1d(:)];
else
    dtr1d = [];
end