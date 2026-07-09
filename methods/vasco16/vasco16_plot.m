function vasco16_plot(S, xps, h, h2)
% function vasco16_plot(S, xps, h, h2)

if (nargin < 4), h2 = []; end



% fit function
m = vasco16_1d_data2fit(S, xps, vasco16_opt);

% correct potential drift between scans
if (max(xps.s_ind) == 2)
    S(xps.s_ind == 2) = S(xps.s_ind == 2) * m(6);
    m = vasco16_1d_data2fit(S, xps, vasco16_opt);
end




% % find unique fc's
fc_vals = round( 100 * xps.alpha2 ./ (xps.b + eps) ) / 100;

fc_vals_uni = unique(fc_vals);

cmap = [1 0 0; 0 0 1; 0 0 0];

cla(h);
hold(h, 'off');

for c = 1:numel(fc_vals_uni)
    
    ind = fc_vals == fc_vals_uni(c);

    semilogy(h, xps.b(ind) * 1e-9, S(ind) / m(1), 'o', 'color', cmap(c,:), ...
        'markersize', 5, 'markerfacecolor', cmap(c,:));
    hold(h, 'on');
    
    clear xps2;
    xps2.n = 32;
    xps2.b = linspace(eps, max(xps.b(:)) * 1.1, xps2.n);
    xps2.s_ind = median(xps.s_ind(ind));
    xps2.alpha2 = fc_vals_uni(c) * xps2.b;
        
    S_fit = vasco16_1d_fit2data(m, xps2);
    
    semilogy(h, xps2.b * 1e-9, S_fit / m(1), '-', 'color', 'white', 'linewidth', 3);
    semilogy(h, xps2.b * 1e-9, S_fit / m(1), '-', 'color', cmap(c,:), 'linewidth', 2);
end

axis(h, 'on');
box(h, 'off');
set(h, 'tickdir','out');

S_eff = S(:) / m(1);

ylim(h, [0.9 * min(S_eff(:)) 1.1 * max(S_eff(:)) ]);

xlabel(h, 'b [um^2/ms]');
ylabel(h, 'Signal');

% m = [s0, vd2, f_blood, D_blood, D_tissue, w]
title(h, sprintf(['f=%.1f%%, D_b/D_t=%.2f/%.2f um^2/ms\n' ...
                  'vd=%.2f mm/s, w=%.2f'], ...
    m(3)*100, m(4)*1e9, m(5)*1e9, sqrt(m(2))*1e3, m(6)));

% 
% 
% % show legend
% if (~isempty(h2))
%     
%     l_str = cell(1,numel(b_delta_uni));
%     for c = 1:numel(b_delta_uni)
%         plot(h2,10,10,'-', 'color', cmap(c,:), 'linewidth', 2);
%         hold(h2, 'on');
%         l_str{c} = ['b_\Delta = ' num2str(b_delta_uni(c))];
%     end
%     ylim(h2, [-1 1]);
%     legend(h2, l_str, 'location', 'northwest');
%     axis(h2, 'off');
%     
%     
% end



% title(h, sprintf('v(at) = %0.2f, v(fw) = %0.2f, mdt = %0.2f', m(2), m(3), m(4) * 1e9));
