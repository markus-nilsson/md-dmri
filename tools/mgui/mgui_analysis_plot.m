function mgui_analysis_plot(method_name, S, xps, xps_fn, h, c_volume)
% function mgui_analysis_plot(method_name, S, xps, xps_fn, h, c_volume)

if (nargin < 6), c_volume = []; end

% Clear content
for c = 1:2, cla(h(c), 'reset'); axis(h(c), 'off'); end

% Pull together method functions
plot_fun_name   = [method_name '_plot'];
fun_1d_data2fit = [method_name '_1d_data2fit'];
fun_1d_fit2data = [method_name '_1d_fit2data'];
fun_opt         = [method_name '_opt'];
fun_check       = [method_name '_check_xps'];

% convenient format for the models
MS = mean(S, 2);

for c_attempt = 1:9
    
    try
        switch (c_attempt)
            
            case 1 % no signal -> show standard message
                if (numel(S) == 0)
                    mgui_analysis_plot_message(h(1), ...
                        '---> Draw ROI to get going');
                end
                
            case 2 % overview asked for
                if (~strcmp(method_name, 'Overview')), continue; end
                
                if (size(S,1) == 1) % one volume only --> histogram
                    mgui_analysis_plot_histogram(h(1), S);
                else
                    mgui_analysis_plot_signal(h(1), S, [], c_volume);
                end
                
            case 3 % report if there is no *_check_xps function
                if (~exist([fun_check '.m'], 'file'))
                    
                    mgui_analysis_plot_message(h(1), ...
                        sprintf('%s not found', fun_check));
                end
                
            case 4 % test the *_xps_check and report if it throws an error
                try
                    feval(fun_check, xps);
                catch me
                    mgui_analysis_plot_message(h(1), ...
                        sprintf('%s error:\n%s', fun_check, me.message));
                end
                
            case 5 %  try standard plot function
                feval(plot_fun_name, MS, xps, h(1), h(2));
                
            case 6 %  try with magnitude data, if needed
                if (~all(isreal(MS(:))))
                    feval(plot_fun_name, abs(MS), xps, h(1), h(2));
                    warning('Performed analysis on magnitude of complex data');
                end
                
            case 7 %  try with one argument less
                feval(plot_fun_name, MS, xps, h(1));
                
            case 8 % show data with fitted model only
                
                opt = feval(fun_opt);
                m = feval(fun_1d_data2fit, MS, xps, opt);
                S_fit = feval(fun_1d_fit2data, m, xps);
                
                mgui_analysis_plot_signal(h(1), S, S_fit, c_volume);
                
            case 9 % at last, provide error message
                mgui_analysis_plot_message(h(1), 'Could not fit or plot');
        end
        
    catch me
        fprintf('%s err: %s (%s)\n', plot_fun_name, me.message, me.stack(1).name);
    end
    
    % something was plotted, yeah!
    if (~isempty(get(h(1), 'children')))
        break;
    end
end


% Add xps info to the bottom if its available
if (isempty(get(h(2), 'children')))
    
    try
        msg = mdm_xps_info(xps, method_name, [], xps_fn);
    catch me
        disp(me.message);
        msg = 'Could not run mdm_xps_info';
    end
    
    mgui_analysis_plot_message(h(2), msg);
    
end










