function mgui_analysis_plot_histogram(h, S)
% function mgui_analysis_plot_histogram(h, S)

hold(h, 'off'); 
Nbins = 20;
edges = linspace(0,max(S,[],'all'),Nbins);
[counts,~] = histcounts(S,edges);
hh = histogram(h,'BinEdges', edges, 'BinCounts', counts);

% ylim = max([counts(2:(end-1))])*[-.1 1.1];
% set(h,'YLim',ylim)

set(hh,'DisplayStyle','stairs','EdgeColor','k','LineWidth',1)

tmp = S(~isnan(S(:)));
title(h, {...
    sprintf('Mean (std): %1.2f (%1.2f)', mean(tmp), std(tmp)), ...
    sprintf('Min/max: %1.2f/%1.2f', min(tmp), max(tmp))});

