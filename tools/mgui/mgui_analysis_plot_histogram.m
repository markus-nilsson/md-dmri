function mgui_analysis_plot_histogram(h, S)
% function mgui_analysis_plot_histogram(h, S)

hold(h, 'off'); 
hist(h, S);
tmp = S(~isnan(S(:)));
title(h, {...
    sprintf('Mean (std): %1.2f (%1.2f)', mean(tmp), std(tmp)), ...
    sprintf('Min/max: %1.2f/%1.2f', min(tmp), max(tmp))});

