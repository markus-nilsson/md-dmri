function [n,par,perp,theta,phi,r1,r2,w] = dtr1r2d_dist2par(dtr1r2d)

n = dtr1r2d(1);

if n>0
    m = numel(dtr1r2d(2:end))/n;
    dtr1r2d_array = reshape(dtr1r2d(2:end),[m n]);
    par = dtr1r2d_array(1,:)';
    perp = dtr1r2d_array(2,:)';
    theta = dtr1r2d_array(3,:)';
    phi = dtr1r2d_array(4,:)';
    r1 = dtr1r2d_array(5,:)';
    r2 = dtr1r2d_array(6,:)';
    w = dtr1r2d_array(7,:)';
else
    par = [];
    perp = [];
    theta = [];
    phi = [];
    r1 = [];
    r2 = [];
    w = [];
end
