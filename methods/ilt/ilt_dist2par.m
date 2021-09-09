function [n,D,w] = ilt_dist2par(dd)

n = dd(1);

if n>0
    m = numel(dd(2:end))/n;
    dtd_array = reshape(dd(2:end),[m n]);
    D = dtd_array(1,:)';
    w = dtd_array(2,:)';
else
    D = [];
    w = [];
end
