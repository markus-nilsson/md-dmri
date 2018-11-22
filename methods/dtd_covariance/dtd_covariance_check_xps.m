function dtd_covariance_check_xps(xps, opt)
% function dtd_covariance_check_xps(xps)
% 
% checks that all required fields are found in the xps

if (nargin < 2), opt = []; end

mdm_xps_check(xps);

required_fields = {'n', 'bt'};

for c = 1:numel(required_fields)
    if (~isfield(xps, required_fields{c}))
        error('xps.%s not found', required_fields{c});
    end
end
    
% Check that the b-tensors produce an invertible matrix
opt = dtd_covariance_opt(opt);

tmp = warning('query'); warning off; % probe without throwing warning
[~,cond] = dtd_covariance_1d_data2fit(abs(randn(xps.n,1)), xps, opt);
warning(tmp);

if (cond < 1e-10)
    error('The b-tensors cannot form an overdetermined equation system (cond = %s)', ...
        num2str(cond));
end