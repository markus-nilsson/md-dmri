function [n,par,perp,theta,phi,r1,w] = dtr1d_dist2par(dtr1d)

n = dtr1d(1);

if n>0
    m = numel(dtr1d(2:end))/n;
    dtr1d_array = reshape(dtr1d(2:end),[m n]);
    par = dtr1d_array(1,:)';
    perp = dtr1d_array(2,:)';
    theta = dtr1d_array(3,:)';
    phi = dtr1d_array(4,:)';
    r1 = dtr1d_array(5,:)';
    w = dtr1d_array(6,:)';
else
    par = [];
    perp = [];
    theta = [];
    phi = [];
    r1 = [];
    w = [];
end
