function m = dtr1d_dtr1d2m(dtr1d,opt)

m = zeros(1 + 6*opt.dtr1d.n_out,1);
if ~isempty(dtr1d)
    m(1:numel(dtr1d)) = dtr1d;
    m = m(1:(1 + 6*opt.dtr1d.n_out),1);
    m(1) = min([dtr1d(1) opt.dtr1d.n_out]);
end
m = m';
