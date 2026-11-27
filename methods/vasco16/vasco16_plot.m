function m = vasco16_plot(S, xps, h, h2, opt)
% function m = vasco16_plot(S, xps, h, h2, opt)
% Fit original signals once; normalize each series only for display.

if (nargin < 5), opt = vasco16_opt; end
if (nargin < 4), h2 = []; end

vasco16_check_xps(xps);
m = vasco16_1d_data2fit(S, xps, opt);
S_fit = vasco16_1d_fit2data(m, xps);

% The model baseline is s0*w for series 1 and s0 for series 2.
baseline = m(1) * ones(xps.n, 1);
baseline(xps.s_ind == 1) = m(1) * m(6);
S_eff = S(:) ./ baseline;
S_fit_eff = S_fit(:) ./ baseline;

cmap = [1 0 0; 0 0 1];
series_names = {'FC', 'NC'};
data_handles = gobjects(2, 1);

cla(h);
hold(h, 'off');

for c = 1:2
    ind = find(xps.s_ind == c);
    marker = 'o';
    if (c == 1), marker = '^'; end
    data_handles(c) = semilogy(h, xps.b(ind) * 1e-6, S_eff(ind), ...
        marker, 'color', cmap(c,:), 'markersize', 5, ...
        'markerfacecolor', cmap(c,:));
    hold(h, 'on');

    % Connect predictions at acquired encodings; do not assume alpha2/b
    % is constant or extrapolate beyond the measured b-values.
    [b_sorted, order] = sort(xps.b(ind));
    semilogy(h, b_sorted * 1e-6, S_fit_eff(ind(order)), '-', ...
        'color', cmap(c,:), 'linewidth', 2);
end

axis(h, 'on');
box(h, 'off');
set(h, 'tickdir','out');
ylim(h, [0.9 * min(S_eff(:)) 1.1 * max(S_eff(:))]);

xlabel(h, 'b [s/mm^2]');
ylabel(h, 'Signal / fitted series baseline');
legend(h, data_handles, series_names, 'location', 'best', 'box', 'off');

% m = [s0, vd2, f_blood, D_blood, D_tissue, w]
title(h, sprintf(['f=%.1f%%, D_b/D_t=%.2f/%.2f um^2/ms\n' ...
    'vd=%.2f mm/s, w=%.2f'], ...
    m(3)*100, m(4)*1e9, m(5)*1e9, sqrt(m(2))*1e3, m(6)));
