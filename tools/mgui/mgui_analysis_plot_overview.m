function mgui_analysis_plot_overview(S, xps, h_top, h_bottom, S_fit)
% function mgui_analysis_plot_overview(S, xps, h_top, h_bottom)

if (isempty(S))
    axes(h_top);
    cla;
    text(0, 0, 'Draw ROI');
    ylim([-1 1]);
    xlim([0 10]);
    axis(h_top, 'off');
    axis(h_bottom, 'off');
    return;
end

col_gray = [0.0 0.0 0.0] + 0.7;
col_red  = [0.8 0.0 0.0];

xps = msf_ensure_field(xps, 'n', size(S,2));

x = 1:xps.n;
MS = mean(S, 1)';

hold(h_top, 'on');

if (size(S, 1) < 50)
    
    % Deal with complex signals
    if (any(~isreal(S(:))))
        S_plot = abs(S');
        D_plot = std(abs(S), [], 1)';
    else
        S_plot = S';
        D_plot = std(S, [], 1)';
    end
    
    plot(h_top, x, S_plot, '.-', 'color', col_gray);
    
else
    
    if (any(~isreal(S(:))))
        S_plot = abs(MS);
        D_plot = std(abs(S), [], 1)';
    else
        S_plot = MS;
        D_plot = std(S, [], 1)';
    end
    
    plot(h_top, x, S_plot, '-', 'color', col_gray);
    errorbar(h_top, x, S_plot, D_plot, 'k.', 'markersize', 8);
    
    if (isfield(xps, 'c_volume'))
        plot(h_top, x(xps.c_volume), S_plot(xps.c_volume), 'ko', 'markerfacecolor', 'red', 'markersize', 9);
    end
    
end

if (nargin > 4)
    plot(h_top, x, S_fit, '-', 'color', col_red);
end

axis(h_top, 'on');
box(h_top, 'off');
set(h_top, 'tickdir','out', 'ticklength', [0.03 0.1]);

% Compute y-scaling
% if (any(~isreal(S(:))))
%     y_axis = [0 max(abs(S(:)) + eps) * 1.1];
% elseif (min(S(:)) < 0)
%     y_axis = [-1 1] * (max(abs(S(:))) + eps) * 1.1;
% else % standard case
%     y_axis = [0 max(S(:) + eps) * 1.1];
% end

if (min(S_plot(:)) < 0)
    y_axis = [min(min(S_plot-D_plot)) max(max(S_plot+D_plot))] + [-1 1]*(max(max(abs(S_plot)+D_plot)) + eps) * 0.1;
else
    y_axis = [0 max(max(S_plot + D_plot + eps)) * 1.1];
end


axis(h_top, [ [1 xps.n] + [-1 1] * 0.5 y_axis]);

xlabel(h_top, 'Acq number');
ylabel(h_top, 'Signal');
set(h_top, 'xtick', [1 xps.n]);

f = @(x) num2str(getfield(msf_ensure_field(xps, x, NaN), x));

str = {'Info:', ...
    sprintf('xps.n: %s', f('n'))};

text(0,0,str, 'parent', h_bottom);
axis(h_bottom, 'off');

% Add text anotaion that shows mean if few points are included
if numel(x) <= 6
    for it = 1:numel(x)
        mval = mean(S_plot(it, :));
        dval = D_plot(it);
        offset = [range(get(h_top, 'XLim')) range(get(h_top, 'YLim'))]*0.03;
        text(h_top, x(it)+offset(1), mval+offset(2), {sprintf('%0.1e', mval); [char(177) sprintf(' %0.1e', dval)]}, 'fontsize', 7);
    end
end

% Switch to log y-axis if dynamic range is larger than 100
if all(S_plot(:) > 0) && range([min(S_plot(:))/max(max(S_plot+D_plot)) 1]) > 10
    set(h_top, 'YScale', 'log')
end
