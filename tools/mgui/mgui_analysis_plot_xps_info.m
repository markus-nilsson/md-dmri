function mgui_analysis_plot_xps_info(h, xps)
% function mgui_analysis_plot_xps_info(h, xps)

cla(h, 'reset'); 
axis(h, 'off');
text(h,0,0, mdm_xps_info(xps,'general'));

xlim(h, [0 1] + 0.20);
ylim(h, [0 1] - 0.25);

