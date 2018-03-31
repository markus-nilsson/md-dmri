function dps = tm_kt_to_dps(kt, dps, f_reshape)
% function dps = tm_kt_to_dps(dt, dps, f_shape)
%
% kt  - kurtosis tensor(s) in 1x15 format
% dps - display parameter structure 
%         (must have dps.MD field from tm_dt_to_dps with diffusion tensor)
%
% optional
%
% f_reshape - function to reshape output parameters
%
% output:
% dps.(FA, MD, ad, rd, u, FA_col)

if (nargin < 2), dps = []; end
if (nargin < 3), f_reshape = @(x,n) x; end

% fourth order tensor operators needed for the  calculations
% compute it from the average on the sphere (icosa sufficient!)
E_iso_1x15 = mean(tm_1x3_to_1x15(uvec_icosa),1);

dps.V_tot  = f_reshape(tm_inner(kt, E_iso_1x15), 1);
dps.MK     = 3 * (dps.V_tot * 1e18) ./ ( (dps.MD * 1e9).^2 + eps);
