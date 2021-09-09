function dtr2d = dtr2d_par2dist(par,perp,theta,phi,r2,w)

n = numel(par);

if n>0
    dtr2d = [par'; perp'; theta'; phi'; r2'; w'];
    dtr2d = [n; dtr2d(:)];
else
    dtr2d = [];
end