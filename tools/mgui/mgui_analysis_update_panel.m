function EG = mgui_analysis_update_panel(EG, varargin) 
% function EG = mgui_analysis_update_panel(EG, do_reload, do_update)

% currently, we don't separate reload and update
% if (nargin < 2), do_reload = 1; end;
% if (nargin < 3), do_update = 1; end

EG.roi = msf_ensure_field(EG.roi, 'xps', []);

% get handles
h_top    = EG.handles.h_analysis_top_axes;
h_bottom = EG.handles.h_analysis_bottom_axes;
h_popup  = EG.handles.h_analysis_popup;


% get current selection
str = get(h_popup, 'String');
try
    current_method = strrep(str{get(h_popup, 'Value')}, ' (x)', '');
catch
    current_method = {};
end

% repopulate only if there's a new xps coming in 
EG.analysis.present = 1;
EG.analysis = msf_ensure_field(EG.analysis, 'xps_fn', []);
if (~strcmp(EG.analysis.xps_fn, EG.roi.xps_fn))
    EG.analysis.xps_fn = EG.roi.xps_fn;

    % Check which methods that are available
    d = dir(fullfile(fileparts(mfilename('fullpath')), '..', '..','methods'));
    
    % Set default method
    str = {'Overview'};
    method_name = {'Overview'};
    
    % Populate popup with additional methods
    for c = 1:numel(d)
        if (d(c).name(1) ~= '.') && (d(c).isdir)
            
            f_name = [d(c).name '_check_xps'];
            
            try
                % currently the check xps functions throw errors
                feval(f_name, msf_rmfield(EG.roi.xps, 'xps_fn'));
                str{end+1} = d(c).name;
                
            catch me
                % show that the method does not work with an (x) appended
                % to the method name
                str{end+1} = [ d(c).name ' (x)'];
                
                if (1)
                    disp(me.message);
                end
            end
            
            method_name{end+1} = d(c).name;
        end
    end
    
    set(h_popup, 'String', str);
    
    % Determine the selected method
    value = -1;
    for c = 1:numel(str)
        if (strcmp(method_name{c}, current_method))
            value = c;
            break;
        end
    end
    
    % make sure the selection and the determined method is consistent
    if (value > -1), set(h_popup, 'value', value); end
    if (get(h_popup, 'value') > numel(str)), set(h_popup, 'value', 1); end
    
end

% Pull out signal in MxN format where M is n_dynamics and N roi size
if (msf_isfield(EG, 'roi') && ...
        msf_isfield(EG.roi, 'I') && ...
        msf_isfield(EG.roi, 'I_roi') && ...
        any(EG.roi.I_roi(:) > 0))
    
    % only load the signal once
    if (~isfield(EG,'analysis') || ~isfield(EG.analysis, 'S'))
        S = zeros(size(EG.roi.I,4), sum(EG.roi.I_roi(:)));
        for c = 1:size(EG.roi.I,4)
            tmp = EG.roi.I(:,:,:,c);
            S(c,:) = tmp(EG.roi.I_roi(:) > 0);
        end
        
        EG.analysis.S = S;
    else
        S = EG.analysis.S;
    end
    
else
    S = [];
end

mgui_analysis_plot(current_method, ...
    S, EG.roi.xps, EG.analysis.xps_fn, [h_top, h_bottom], EG.roi.c_volume);


