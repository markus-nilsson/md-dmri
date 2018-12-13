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
[~,cond] = dtd_covariance_1d_data2fit(exp(-xps.bt * [1 1 1 0 0 0]' * 1e-9), xps, opt);
warning(tmp);

if (cond < opt.dtd_covariance.cond_limit)
    
    try
        mdm_xps_info(xps, 'dtd_covariance', opt);
    catch
        disp('Unable to provide xps information');
    end
    
    error('Equation system not overdetermined (cond = %1.1e)', cond);
    
    
end