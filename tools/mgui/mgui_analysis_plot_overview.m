function mgui_analysis_plot_overview(S, xps, h_top, h_bottom, S_fit, c_volume)
% function mgui_analysis_plot_overview(S, xps, h_top, h_bottom)

if (nargin < 4), h_bottom = []; end
if (nargin < 5), S_fit = []; end
if (nargin < 6), c_volume = []; end

 
% Decide what to show at the top
if (~isempty(h_top))
    axis(h_top, 'off');
    
    if (isempty(S))
        mgui_analysis_plot_message(h_top, '---> Draw ROI to get going');
        
    elseif (size(S,1) == 1) % one volume only
        mgui_analysis_plot_histogram(h_top, S);
        
    else
        xps = msf_ensure_field(xps, 'c_volume', []);
        mgui_analysis_plot_signal(h_top, S, S_fit, c_volume);
    end
end

% Decide what to show at the bottom
if (~isempty(h_bottom))
    axis(h_bottom, 'off');
    
    if (isfield(xps, 'xps_fn') && (xps.n > 1))
        mgui_analysis_plot_xps_info(h_bottom, xps);
    else
        cla(h_bottom, 'reset'); axis(h_bottom, 'off');
    end
    
end



    function mgui_analysis_plot_histogram(h, S)
        cla(h, 'reset');
        hist(h, S);
        tmp = S(~isnan(S(:)));        
        title(h, {...
            sprintf('Mean (std): %1.2f (%1.2f)', mean(tmp), std(tmp)), ...
            sprintf('Min/max: %1.2f/%1.2f', min(tmp), max(tmp))});
            
    end



    function mgui_analysis_plot_signal(h, S, S_fit, c_volume)

        
        % Deal with complex signals
        if (any(~isreal(S(:))))
            S_plot = abs(S);
            D_plot = std(abs(S), [], 2);
        else
            S_plot = S;
            D_plot = std(S, [], 2);
        end
        
        % Compute plot axes
        if (min(S_plot(:)) < 0)
            y_axis = [...
                min(min(S_plot-D_plot)) ...
                max(max(S_plot+D_plot))] + ...
                [-1 1]*(max(max(abs(S_plot)+D_plot)) + eps) * 0.1;
        else
            y_axis = [0 max(max(S_plot + D_plot + eps)) * 1.1];
        end        
        
        
        % Plot the signal
        cla(h, 'reset'); hold(h, 'on');
        x = 1:size(S,1);
        col_gray = [0.0 0.0 0.0] + 0.7;
        col_red  = [0.8 0.0 0.0];        
                
        if (size(S, 1) < 50) % small ROI
            plot(h, x, S_plot, '.-', 'color', col_gray);
            
        else % larger ROI            
            plot(h, x, mean(S_plot, 2), '-', 'color', col_gray);
            errorbar(h, x, mean(S_plot, 2), D_plot, 'k.', 'markersize', 8);
        end
        
        if (~isempty(c_volume))
            plot(h, x(c_volume), mean(S_plot(c_volume, :)), 'ko', ...
                'markerfacecolor', 'red', ...
                'markersize', 9);
        end
                
        if (~isempty(S_fit))
            plot(h, x, S_fit, '-', 'color', col_red);
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
                    mean(S_plot(c, :)) + 0.03 * range(get(h, 'YLim')), ...
                    sprintf('%0.1e\n%s%0.1e', mean(S_plot(c, :)), char(177), D_plot(c)), ...
                    'fontsize', 7);
            end
        end               

    end



end