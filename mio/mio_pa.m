function A = mio_pa(I, xps, opt)
% function A = mio_pa(I, xps, opt)

if (nargin < 3), opt = []; end

opt = mdm_opt(opt);

% figure out which b-tensors to average
[~,c_list, id_ind] = mdm_pa_ind_from_xps(xps);

A = zeros(size(I,1), size(I,2), size(I,3), n);

for c = c_list'
    A(:,:,:,c == c_list) = msf_nanmean(double(I(:,:,:,id_ind == c)),4);
end

if (opt.do_pa_abs), A = abs(A); end


