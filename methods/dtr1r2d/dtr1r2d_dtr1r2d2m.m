function m = dtr1r2d_dtr1r2d2m(dtr1r2d,opt)

m = zeros(1 + 7*opt.dtr1r2d.n_out,1);
if ~isempty(dtr1r2d)
    m(1:numel(dtr1r2d)) = dtr1r2d;
    m = m(1:(1 + 7*opt.dtr1r2d.n_out),1);
    m(1) = min([dtr1r2d(1) opt.dtr1r2d.n_out]);
end
m = m';
