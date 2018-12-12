function mgui_analysis_plot_signal(h, S, S_fit, c_volume)
% function mgui_analysis_plot_signal(h, S, S_fit, c_volume)
%
% h - handle to axes
% S - size MxN, where M is number of volumes and N is the ROI size
% S_fit - size Mx1 (optional)
% c_volume - index refering to highlighted volume (optional)

if (nargin < 3), S_fit = []; end
if (nargin < 4), c_volume = []; end

% Deal with complex signals
if (any(~isreal(S(:)))), S = abs(S); end

M = mean(S, 2);
D = std(S, [], 2);

% Compute plot axes
if (min(S(:)) < 0)
    y_axis = [min(M(:)-D(:)) max(M(:)+D(:))] + ...
        [-1 1]*(max(abs(M(:))+D(:)) + eps) * 0.1;
else
    y_axis = [0 (max(M(:) + D(:)) + eps) * 1.1];
end


% Plot the signal
cla(h, 'reset'); hold(h, 'on');
x = 1:size(S,1);
col_gray = [0.0 0.0 0.0] + 0.7;
col_red  = [0.8 0.0 0.0];

if (size(S, 2) < 50) % small ROI
    plot(h, x, S, 'o-', 'color', 'black', ...
        'markerfacecolor', col_gray, 'markersize', 6);    
else % larger ROI
    plot(h, x, mean(S, 2), '-', 'color', col_gray, 'linewidth', 2);
    errorbar(h, x, mean(S, 2), D, 'ko', ...
        'markerfacecolor', col_gray, 'markersize', 8);
end

if (~isempty(c_volume))
    plot(h, x(c_volume), mean(S(c_volume, :)), 'ko', ...
        'markerfacecolor', 'red', ...
        'markersize', 9);
end

if (~isempty(S_fit))
    plot(h, x, S_fit, '-', 'color', col_red, 'linewidth', 2);
end


% Setup the plot
axis(h, 'on');
box(h, 'off');
set(h, 'tickdir','out', 'ticklength', [0.03 0.1]);
axis(h, [ [1 max(x)] + [-1 1] * 0.5 y_axis]);
xlabel(h, 'Acq number');
ylabel(h, 'Signal');
set(h, 'xtick', [1 max(x)]);


% Add text anotaion that shows mean, if few points are included
if (max(x) <= 6)
    for c = 1:max(x)
        text(h, ...
            x(c) + 0.03 * range(get(h, 'XLim')), ...
            mean(S(c, :)) + 0.03 * range(get(h, 'YLim')), ...
            sprintf('%0.1e\n%s%0.1e', mean(S(c, :)), char(177), D(c)), ...
            'fontsize', 7);
    end
end

