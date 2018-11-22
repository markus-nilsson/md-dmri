function A = mio_pa(I, xps, opt)
% function A = mio_pa(I, xps, opt)
%
% opt.mio.pa.method - ari or geo

if (nargin < 3), opt = []; end

opt = mio_opt(opt);

% figure out which b-tensors to average
[~,c_list, id_ind] = mdm_pa_ind_from_xps(xps, opt);

A = zeros(size(I,1), size(I,2), size(I,3), numel(c_list));

switch (opt.mio.pa.method)
    case 'geo' % not really powder averaging, should rename function
        f = @(x) msf_nangeomean(x, 4);
    case 'ari'
        f = @(x) msf_nanmean(x, 4);
    case 'median'
        f = @(x) median(x, 4);
    otherwise
        error('unknown averaging method');
end

for c = c_list'
    A(:,:,:,c == c_list) = f(double(I(:,:,:,id_ind == c)));
end

if (opt.mio.pa.do_abs), A = abs(A); end



