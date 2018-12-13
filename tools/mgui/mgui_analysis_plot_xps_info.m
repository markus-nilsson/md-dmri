function mgui_analysis_plot_xps_info(h, xps, method_name, xps_fn)
% function mgui_analysis_plot_xps_info(h, xps, method_name)

if (nargin < 3), method_name = 'general'; end

msg = mdm_xps_info(xps, method_name, [], xps_fn);
mgui_analysis_plot_message(h, msg); 
