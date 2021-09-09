function dtd = dtd_par2dist(par,perp,theta,phi,w)

n = numel(par);

if n>0
    dtd = [par'; perp'; theta'; phi'; w'];
    dtd = [n; dtd(:)];
else
    dtd = [];
end