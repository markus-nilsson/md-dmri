function m = dtr2d_dtr2d2m(dtr2d,opt)

m = zeros(1 + 6*opt.dtr2d.n_out,1);
if ~isempty(dtr2d)
    m(1:numel(dtr2d)) = dtr2d;
    m = m(1:(1 + 6*opt.dtr2d.n_out),1);
    m(1) = min([dtr2d(1) opt.dtr2d.n_out]);
end
m = m';
