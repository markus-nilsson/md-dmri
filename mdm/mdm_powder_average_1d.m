function [signal_pa,xps_pa] = mdm_powder_average_1d(signal, xps, opt)
% function [signal_pa,xps_pa] = mdm_powder_average_1d(signal, xps, opt)
%
% Returns a powder-average of a 1d signal

if (nargin < 3), opt = []; end 
opt = mdm_opt(opt);

[~,c_list, id_ind] = mdm_pa_ind_from_xps(xps,opt);

signal_pa = zeros(numel(c_list), 1);
for c = c_list'
    signal_pa(c == c_list,1) = msf_nanmean(signal(id_ind == c,1),1);
end

% Average fields in xps
xps_pa = mdm_xps_pa(xps,opt);
