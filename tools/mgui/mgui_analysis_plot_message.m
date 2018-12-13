function mgui_analysis_plot_message(h, msg)
% function mgui_analysis_plot_message(h, msg)

msg = strrep(strrep(msg, '\_', '_'), '_', '\_');

cla(h, 'reset'); 
axis(h, 'off');
h_txt = text(h, 0, 0, msg);

xtent = get(h_txt,'Extent');

xlim(h, [0 1] + 0.20);
ylim(h, [0 1] - xtent(2) - 1);
% 
% axis(h, 'on');
% box(h,'on');