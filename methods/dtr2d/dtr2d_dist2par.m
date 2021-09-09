function [n,par,perp,theta,phi,r2,w] = dtr2d_dist2par(dtr2d)

n = dtr2d(1);

if n>0
    m = numel(dtr2d(2:end))/n;
    dtr2d_array = reshape(dtr2d(2:end),[m n]);
    par = dtr2d_array(1,:)';
    perp = dtr2d_array(2,:)';
    theta = dtr2d_array(3,:)';
    phi = dtr2d_array(4,:)';
    r2 = dtr2d_array(5,:)';
    w = dtr2d_array(6,:)';
else
    par = [];
    perp = [];
    theta = [];
    phi = [];
    r2 = [];
    w = [];
end
