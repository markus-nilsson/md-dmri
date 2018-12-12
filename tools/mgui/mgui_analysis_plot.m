function mgui_analysis_plot(model_name, S, xps_in, h_top, h_bottom, c_volume)
% function mgui_analysis_plot(model_name, S, xps_in, h_top, h_bottom, c_volume)

if (nargin < 6), c_volume = []; end 

% Remove internal xps baggage
xps = msf_rmfield(xps_in, 'xps_fn');

% Clear content
cla(h_top, 'reset'); cla(h_bottom, 'reset');    

plot_fun_name   = [model_name '_plot'];
fun_1d_data2fit = [model_name '_1d_data2fit'];
fun_1d_fit2data = [model_name '_1d_fit2data'];
fun_opt         = [model_name '_opt'];
fun_check       = [model_name '_check_xps'];

% convenient format for the models
MS = mean(S, 2);

% First check that the xps is ok
g = @(x) strrep(x, '_', '\_');
if (exist([fun_check '.m'], 'file'))
    try % default option
        feval(fun_check, xps);
        c_attempt_list = 1:6;
        txt_from_check = [];
    catch me
        c_attempt_list = 6;
        txt_from_check = g(me.message);
    end
else
    c_attempt_list = 6;
    txt_from_check = sprintf('%s not defined', g(fun_check));
end

for c_attempt = c_attempt_list
    
    try 
        switch (c_attempt)
            
            case 1 % show standard message if there is no signal
                if (numel(S) > 0), continue; end
                mgui_analysis_plot_overview(S, xps_in, h_top, h_bottom);
            
            case 2 %  try standard plot function
                if (~exist([plot_fun_name '.m'], 'file')), continue; end
                feval(plot_fun_name, MS, xps, h_top, h_bottom);
            
            case 3 %  try with magnitude data, if needed
                if (~exist([plot_fun_name '.m'], 'file')), continue; end
                if (all(isreal(MS(:)))), continue; end
                warning('Performed analysis on magnitude of complex data');
                feval(plot_fun_name, abs(MS), xps, h_top, h_bottom);
            
            case 4 %  try with an argument less
                if (~exist([plot_fun_name '.m'], 'file')), continue; end
                feval(plot_fun_name, MS, xps, h_top);

            case 5 % show data with fitted model only
                opt = feval(fun_opt);
                m = feval(fun_1d_data2fit, MS, xps, opt);
                S_fit = feval(fun_1d_fit2data, m, xps);
                
                mgui_analysis_plot_overview(S, xps_in, ...
                    h_top, h_bottom, S_fit, c_volume);
            
            case 6 % at last, plot message
                mgui_analysis_plot_message(h_top, ...
                    {'Could not fit/plot selected model', ...
                    txt_from_check});

        end
        
    catch me
        fprintf('%s err: %s\n', plot_fun_name, me.message);
    end
    
    % something was plotted, yeah!
    if (~isempty(get(h_top, 'children')))
        break;
    end
end

% Add something to the bottom if its available
if (isempty(get(h_bottom, 'children')))
    mgui_analysis_plot_xps_info(h_bottom, xps_in);
end


                    
        
        





