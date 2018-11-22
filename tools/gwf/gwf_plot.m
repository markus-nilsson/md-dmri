function gwf_plot(gwf, rf, dt, opt)
% function gwf_plot(gwf, rf, dt, opt)
%
% gwf - n x (1, 2, or 3)  [gradient as executed by amplifier]
% rf  - n x 1             [effect of RF pulses, either 1 or -1]
% dt  - 1 x 1             [time step]
% opt - option structure

if (nargin < 4), opt = []; end

opt = gwf_opt(opt);

opt.gwf = msf_ensure_field(opt.gwf, 'plot_gmax', max(abs(gwf(:)) * 1.1));


% init and test things
[g_eff, t] = gwf_to_g_eff(gwf, rf, dt);

if (any(opt.gwf.plot_t_rf_ex > 0) || any(opt.gwf.plot_t_rf_echo > 0))
    g_plot = gwf;
else
    g_plot = g_eff;
end
    
% plot gwf
for c = 1:size(gwf, 2)
    area(t * 1e3, g_plot(:, c) * 1e3, ...
        'FaceAlpha', opt.gwf.gwf_facealpha(c), ...
        'EdgeColor', 'black', ...
        'FaceColor', opt.gwf.col{c}, ...
        'LineWidth', opt.gwf.gwf_linew); hold on;
end

xlabel('t [ms]');
ylabel('g [mT/m]');

xlim([min(t - 3e-3) max(t + 3e-3)] * 1e3);
ylim([-1 1] * opt.gwf.plot_gmax * 1e3);

box off;
set(gca,'tickdir', 'out', 'ticklength', [0.03 0.05]);
set(gca,'linewidth', 2);
title('Effective gradient');

fn = {'plot_t_rf_ex', 'plot_t_rf_echo'};
for c = 1:numel(fn)
    if all(~isempty(opt.gwf.(fn{c})))
        if (numel(opt.gwf.(fn{c})) ~= 2)
            error(['expected numel(opt.gwf.' fn{c} ') = 2']);
        end
        
        t_tmp = linspace(opt.gwf.(fn{c})(1), opt.gwf.(fn{c})(2), 100) * 1e3;
        x     = linspace(-3, 3, numel(t_tmp));
        sc = diff(ylim) * 0.15 * c;
        
        plot(t_tmp, sinc(x) * sc, 'k', 'LineWidth', opt.gwf.rf_linew, 'Color', [0 0 0] + 0.5);
    end
end

if any(opt.gwf.plot_t_adc > 0)
    x = opt.gwf.plot_t_adc * 1e3;
    y = ylim / 8;
    patch([x(1) x(1) x(2) x(2)], [y(1) y(2) y(2) y(1)], ...
        [0 0 0] + 0.9, ...
        'FaceAlpha', 0.7, ...
        'EdgeColor', 'black', ...
        'FaceColor', [0 0 0] + 0.9, ...
        'LineWidth', 2);
end

if any(opt.gwf.plot_t_te > 0)
    x = opt.gwf.plot_t_te * 1e3;
    y = ylim * 0.5;
    plot([x(1) x(1)], [y(1) y(2)], 'k--');
end


    
    



