function xps_pa = mdm_xps_pa(xps, opt)
% function xps_pa = mdm_xps_pa(xps, opt)
%
% Returns the powder-averaged xps

if (nargin < 2), opt = mdm_opt; end

[~, c_list, id_ind] = mdm_pa_ind_from_xps(xps, opt);

xps_pa = mdm_xps_average(xps, id_ind, c_list, opt);

