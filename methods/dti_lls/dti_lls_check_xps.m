function dti_lls_check_xps(xps)
% function dti_lls_check_xps(xps)
% 
% checks that all required fields are found in the xps

mdm_xps_check(xps);

required_fields = {'n', 'bt'};

for c = 1:numel(required_fields)
    if (~isfield(xps, required_fields{c}))
        error('xps.%s not found', required_fields{c});
    end
end
    


% Check that the b-tensors produce an invertible matrix
opt = dti_lls_opt();

tmp = warning('query'); warning off; % probe without throwing warning
[~,cond] = dti_lls_1d_data2fit(abs(randn(xps.n,1)), xps, opt);
warning(tmp);

if (cond < 1e-10)
    error('The b-tensors cannot form an overdetermined equation system');
end