function dtr1r2d = dtr1r2d_par1dist(par,perp,theta,phi,r1,r2,w)

n = numel(par);

if n>0
    dtr1r2d = [par'; perp'; theta'; phi'; r1'; r2'; w'];
    dtr1r2d = [n; dtr1r2d(:)];
else
    dtr1r2d = [];
end