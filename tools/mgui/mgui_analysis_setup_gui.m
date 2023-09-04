function EG = mgui_analysis_setup_gui(EG, h)
% function EG = mgui_roi_setup_gui(EG, h)


left = 0.20;
width = 0.70;

EG.handles.h_analysis_top_axes = axes(...
    'parent', h, ...
    'units', 'normalized', ...
    'position', [left 0.5 width 0.3], ...
    'fontsize', EG.conf.default_font_size);

axis off;


EG.handles.h_analysis_bottom_axes = axes(...
    'parent', h, ...
    'units', 'normalized', ...
    'position', [left 0.1 width 0.3], ...
    'fontsize', EG.conf.default_font_size);

axis off;



left   = 10; 
bottom = 664;
width  = 200;
height = 15;


EG.handles.h_analysis_popup = uicontrol('style','popupmenu', ...
    'parent', h, ...
    'units', 'pixels', ...
    'position', [left bottom width height], ...
    'string', 'hello', ...
    'tag', EG.t_ANALYSIS_POPUP, ...
    'callback', @mgui_roi_gui_callback);

left = left + width + 10;
width = 100;

EG.handles.h_analysis_redo_button = uicontrol('style','pushbutton', ...
    'parent', h, ...
    'units', 'pixels', ...
    'position', [left bottom width height], ...
    'string', 'Redo', ...
    'tag', EG.t_ANALYSIS_REDO_BUTTON, ...
    'callback', @mgui_roi_gui_callback);


% Handle resizing: Warning for ugly code, needs rethink (XXX)
set(h, 'ResizeFcn', @mgui_browse_resize);
t_fixed_top = {...
    EG.t_ANALYSIS_POPUP, ...
    EG.t_ANALYSIS_REDO_BUTTON};

h_fixed_top = [];
for c = 1:numel(t_fixed_top)
    h_fixed_top = [h_fixed_top findobj('Tag', t_fixed_top{c})];
end
tmp_p1 = get(h_fixed_top(1), 'Position');
tmp_p2 = get(h, 'Position');
d_fixed_top = tmp_p2(4) - tmp_p1(2);


    function mgui_browse_resize(h,varargin)
        
        if (~exist('h_fixed_top', 'var')), return; end
        
        % Ensure we're working in pixels and get the position
        old_units = get(h,'Units');
        set(h,'Units','pixels');
        p_parent = get(h,'Position');
        
        % Keep some elements at top
        for h_elem = h_fixed_top
            p = get(h_elem, 'position');
            p(2) = p_parent(4) - d_fixed_top;
            set(h_elem, 'position', p);
        end
        
        % Enlarge? 
        % later

        % Restore old units
        set(h,'Units',old_units);
    end

end

