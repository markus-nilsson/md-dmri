function mgui_analysis_plot_message(h, msg)
% function mgui_analysis_plot_message(h, msg)

cla(h, 'reset'); 
axis(h, 'off');
text(h, 0, 0, msg);
xlim(h, [0 1] + 0.20);
ylim(h, [0 1] - 1.0);
