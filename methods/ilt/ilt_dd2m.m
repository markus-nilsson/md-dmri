function m = ilt_dd2m(dtd,opt)

m = zeros(1 + 2*opt.ilt.n_out,1);
if ~isempty(dtd)
    m(1:numel(dtd)) = dtd;
end
m = m';
