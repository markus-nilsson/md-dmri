function mgui_analysis_plot_histogram_rgb(h, S)
% function mgui_analysis_plot_histogram(h, S)
% DT 20200315

hold(h, 'off'); 

% Normalize S assuming that the nii was saved as 8-bit integer
S = S/255;

Nbins = 20;
edges = linspace(0,max(S,[],'all'),Nbins);
[counts_r,~] = histcounts(S(1,:),edges);
[counts_g,~] = histcounts(S(2,:),edges);
[counts_b,~] = histcounts(S(3,:),edges);
% [counts_r,~] = histcounts(S(1,:)./sum(S),edges);
% [counts_g,~] = histcounts(S(2,:)./sum(S),edges);
% [counts_b,~] = histcounts(S(3,:)./sum(S),edges);

hh_b = histogram(h,'BinEdges', edges, 'BinCounts', counts_b);
hold(h, 'on'); 
hh_g = histogram(h,'BinEdges', edges, 'BinCounts', counts_g);
hh_r = histogram(h,'BinEdges', edges, 'BinCounts', counts_r);

% ylim = max([counts_r(2:(end-1)) counts_g(2:(end-1)) counts_b(2:(end-1))])*[-.1 1.1];
% set(h,'YLim',ylim)

set([hh_r; hh_g; hh_b],'DisplayStyle','stairs')
set(hh_r,'EdgeColor','r','LineWidth',1)
set(hh_g,'EdgeColor','g','LineWidth',2)
set(hh_b,'EdgeColor','b','LineWidth',3)

% tmp = S(~isnan(S(:)));
% title(h, {...
%     sprintf('Mean (std): %1.2f (%1.2f)', mean(tmp), std(tmp)), ...
%     sprintf('Min/max: %1.2f/%1.2f', min(tmp), max(tmp))});

