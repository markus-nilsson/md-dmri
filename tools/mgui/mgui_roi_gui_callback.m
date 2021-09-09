function EG = mgui_roi_gui_callback(varargin)
% function mgui_roi_gui_callback(varargin)

h_fig = mgui_misc_get_mgui_fig();

if (ishandle(h_fig))  % is GUI already running
    EG = get(h_fig, 'UserData');
else
    error('Eval GUI not initialized');
end

if (~isfield(EG,'roi')), EG.roi.present = 1; end


% Handle input arguments
if (nargin >= 1)
    
    
    if (numel(varargin) >= 2)
        event_info = varargin{2};
        
        if (msf_isfield(event_info, 'Key'))
            switch (event_info.Key)
                case {'leftarrow', 'rightarrow'}
                    EG = mgui_gui_volume_callback(EG, EG.roi.ref, [], event_info);
                case {'uparrow'}
                    EG = mgui_roi_select_volume(EG, -1);
                case {'downarrow'}
                    EG = mgui_roi_select_volume(EG, +1);
                case {'space'}
                    
                    if (EG.roi.function == 1)
                        EG = mgui_roi_set_function(EG, 2);
                    else
                        EG = mgui_roi_set_function(EG, 1);
                    end
                    
                case {'r', 'R'}
                    
                    EG = mgui_waitbar(EG, 0.05, 'Remaking ROI...');                    
                    mgui_roi_load(EG, EG.select, 0, 1);
                    EG.hSender = EG.tags.(EG.t_ROI_PANEL);
                    EG = mgui_roi_update_panel(EG, 1, 1);
                    
                    
                case {'t', 'T'} 

                    EG = mgui_template_view(EG, ...
                        msf_isfield(event_info, 'Character') && strcmp(event_info.Character, 'T'));
                                        
                case {'delete'} % delete ROI
                    
                    my_delete(mgui_roi_filename(EG, EG.select));
                    EG = mgui_roi_update_panel(EG, 1, 1);
                    
                case {'m', 'M'}
                    
                    try
                        EG.roi.is_updated = 1;
                        EG.roi.I_roi = EG.roi.I == 1;
                        EG = mgui_roi_update_panel(EG, 0, 1);
                    catch me
                        disp(me.message);
                    end
                    
                case {'s', 'S'}
                    
                    % xxx: EG.browse.path may not be set when c_mode ~= 2
                    %        --> Switch to EG.roi.path                     
                    
                    [tmp_name, tmp_path] = uiputfile('.nii.gz', 'Save ROI', ...
                        EG.browse.path);
                    roi_filename = fullfile(tmp_path, tmp_name);
                    
                    if (roi_filename ~= 0)
                        try
                            EG.roi.is_updated = 1;
                            EG.roi.roi_filename = roi_filename;
                            EG = mgui_roi_save(EG);
                            EG.roi.roi_filename = []; 
                            EG.roi.is_updated = 0;
                        catch me
                            msgbox(me.message);
                        end
                    end
                    
                case {'l', 'L'}
                    
                    % xxx: EG.browse.path may not be set when c_mode ~= 2
                    %        --> Switch to EG.roi.path                                         
                    
                    [tmp_name, tmp_path] = uigetfile(...
                        {'*.nii;*.nii.gz', 'NIFTI'}, 'Load ROI', ...
                        EG.browse.path);
                    roi_filename = fullfile(tmp_path, tmp_name);
                    
                    if (roi_filename ~= 0)
                        try
                            % XXX: This should probably be done in a little
                            % more elaborate way
                            [I_roi,h] = mdm_nii_read(roi_filename);
                            I_roi = mgui_misc_flip_volume(I_roi, mdm_nii_oricode(h), EG.conf.ori);
                            
                            if (max(I_roi(:) > 1))
                                
                                k = inputdlg({'k'}, 'Label value', 1, {'1'});
                                
                                k = str2num(k{1});
                                
                                if (numel(k) == 1)
                                    l = 0.01;
                                else
                                    l = (k(2) - k(1))/2 + 0.01;
                                    k = (k(2) + k(1))/2;
                                end
                            else
                                k = 1;
                                l = 0.1;
                            end
                            
                            I_roi = (I_roi > (k - l)) & (I_roi < (k + l));
                            
                            EG.roi.is_updated = 1;
                            EG.roi.I_roi = I_roi;
                            EG.roi.c_slice_save = mgui_misc_roi_centre(EG.roi.I_roi);
                            EG.roi.c_slice = EG.roi.c_slice_save(EG.roi.c_dim);
                            EG = mgui_roi_update_panel(EG, 0, 1);
                        catch me
                            msgbox(me.message);
                        end
                    end
                    
                case {'f', 'F'}
                    
                    figure(EG.dict('mgui_figure_nr'));
                    
                case {'b', 'B'}
                    
                    figure(EG.dict('mgui_figure_nr'));
                    print_pdf(fullfile(EG.study_path, [EG.dict('mgui_figure_name') '.pdf']));
                    
                case {'numpad6','numpad4','numpad8','numpad2','numpad3','numpad9', ...
                        '6','4','8','2','3','9'}
                    
                    switch (event_info.Key(end))
                        case {'6'}
                            v_shift = [+1 0 0];
                        case {'4'}
                            v_shift = [-1 0 0];
                        case {'8'}
                            v_shift = [0 +1 0];
                        case {'2'}
                            v_shift = [0 -1 0];
                        case {'3'}
                            v_shift = [0 0 +1];
                        case {'9'}
                            v_shift = [0 0 -1];
                    end
                    
                    EG.roi.I_roi = circshift(EG.roi.I_roi, v_shift);
                    EG.roi.is_updated = 1;
                    EG = mgui_roi_update_panel(EG, 0, 1);

                    
                case {'z', 'Z'}
                    EG = mgui_roi_undo(EG);
                    
                                       
                case {'d', 'D'} % Dimensionality of current image and roi
                   
                    if (isfield(EG.roi, 'I')), disp(['Contrast: ' num2str(size(EG.roi.I))]); end
                    if (isfield(EG.roi, 'I_roi')), disp(['ROI: ' num2str(size(EG.roi.I_roi))]); end
                    
            end
        end
        
        
        % Mouse wheel
        if (numel(varargin) >= 2)
            event_info = varargin{2};
            
            if (msf_isfield(event_info, 'VerticalScrollCount'))
                
                if (isfield(EG, 'roi') || isobject(EG)) && isfield(EG.roi, 'ref')
                    r = EG.roi.ref;
                    p = get(EG.tags.(EG.t_FIG), 'CurrentPoint');
                    w = get(EG.tags.(EG.t_ROI_PANEL), 'Position');
                    
                    if ((p(1) > w(1) && p(1) < w(1) + w(3)) && (p(2) > w(2) && p(2) < w(2) + w(4)))
                        val = (-1) * sign(event_info.VerticalScrollCount);
                        if (isfield(EG.(r.fn), r.In))
                            if (EG.(r.fn).c_slice + val> size(EG.(r.fn).(r.In), EG.(r.fn).c_dim))
                                EG.(r.fn).c_slice = size(EG.(r.fn).(r.In), EG.(r.fn).c_dim);
                            elseif (EG.(r.fn).c_slice + val < 1)
                                EG.(r.fn).c_slice = 1;
                            else
                                EG.(r.fn).c_slice = EG.(r.fn).c_slice + val;
                            end
                            EG = mgui_gui_update_slice_slider(EG, r);
                            EG = r.f_callback(EG);
                            
                            
                        end
                    end
                else
                    % XXX: Temp, move ScrollWheel callback to a generic
                    % function
                    return;
                end
            end
        end
    end
    
    % Handle button presses and similar stuff
    if (ishandle(varargin{1}))
        
        hSender = varargin{1};
        
        % First, see if there are volume tags
        EG = mgui_gui_volume_callback(EG, EG.roi.ref, hSender);

        switch (get(hSender, 'Tag'))

            case EG.t_ROI_PLUS
                EG = mgui_roi_set_function(EG, 1);

            case EG.t_ROI_MINUS
                EG = mgui_roi_set_function(EG, 2);
                
            case EG.t_ROI_WINDOW
                EG = mgui_roi_set_function(EG, 3);
                
            case EG.t_ROI_UNDO
                EG = mgui_roi_undo(EG);

            case EG.t_ROI_CLEAR
                EG = mgui_roi_clear_roi(EG);
                                
            case {EG.t_ROI_WINDOW_MIN, EG.t_ROI_WINDOW_MAX}
                EG = mgui_roi_window_change(EG);
                
            case EG.t_ROI_WINDOW_AUTO
                EG = mgui_roi_window_auto(EG);
                
            case EG.t_ROI_IMAGE
                if (~isfield(EG.roi,'function')), EG.roi.function = 1; end
                switch (EG.roi.function)
                    
                    case {1,2}
                        
                        set(EG.tags.(EG.t_FIG),'WindowButtonMotionFcn', @mgui_roi_draw);
                        set(EG.tags.(EG.t_FIG),'WindowButtonUpFcn', @mgui_roi_draw_stop);
                        set(EG.handles.h_roi_axes,'UserData', []);
                        
                    case 3
                        
                        set(EG.tags.(EG.t_FIG),'WindowButtonMotionFcn', @mgui_gui_volume_window);
                        set(EG.tags.(EG.t_FIG),'WindowButtonUp', @mgui_gui_volume_window_stop);
                        
                end
                    
                
            case {EG.t_ROI_ZOOM_IMAGE{:}}%, 'mgui_ROI_PROJ_X_PLOT'}
                set(EG.tags.(EG.t_FIG),'WindowButtonMotionFcn', @mgui_roi_pan);
                set(EG.tags.(EG.t_FIG),'WindowButtonUp', @mgui_roi_pan_stop);
                
            case EG.t_ROI_ENABLE_OVERVIEW
                EG = mgui_roi_enable_right_panel(EG, 1);
                
            case EG.t_ROI_ENABLE_ANALYSIS
                EG = mgui_roi_enable_right_panel(EG, 2);
                
            case EG.t_ROI_ANALYSIS_PLUS
                EG = mgui_roi_select_volume(EG, +1);
                
            case EG.t_ROI_ANALYSIS_MINUS
                EG = mgui_roi_select_volume(EG, -1);
                
            case EG.t_ROI_ANALYSIS_PLAY
                EG = mgui_roi_analysis_play(EG);
                
            case EG.t_ROI_ANALYSIS_STOP
                EG = mgui_roi_analysis_stop(EG);
                
            case EG.t_ROI_ANALYSIS_PLOT
                EG = mgui_roi_analysis_plot(EG, hSender);
                
                
                % cheap!
            case {EG.t_ANALYSIS_POPUP, EG.t_ANALYSIS_REDO_BUTTON}
                EG = mgui_analysis_update_panel(EG);
                
                
                
        end
    end
end

% Finally, save the handles for next round
set(EG.handles.h_fig, 'UserData', EG);

end


% --------------------------------------------------------------
function EG = mgui_roi_clear_roi(EG)

if (isfield(EG.roi,'I_roi'))
    EG.roi.I_roi_undo = EG.roi.I_roi;
    set(EG.tags.(EG.t_ROI_UNDO), 'enable', 'on');
end
EG.roi.I_roi = mgui_roi_empty(EG);
EG.roi.is_updated = 1;
EG.roi = msf_rmfield(EG.roi,'S');
EG = mgui_roi_update_panel(EG, 0, 1);

end

% --------------------------------------------------------------
function EG = mgui_roi_window_change(EG)

EG.roi.caxis = [...
    str2double(get(EG.tags.(EG.t_ROI_WINDOW_MIN), 'String'));
    str2double(get(EG.tags.(EG.t_ROI_WINDOW_MAX), 'String'))];

EG = mgui_roi_update_panel(EG, 0, 1);
    
end

% --------------------------------------------------------------
function EG = mgui_roi_window_auto(EG)

if (msf_isfield(EG, 'roi'))
    EG.roi = msf_rmfield(EG.roi, 'caxis');
end

EG = mgui_roi_update_panel(EG, 0, 1);

end



% ------------------------------------------------------------
function EG = mgui_roi_select_volume(EG, value)


EG.roi.c_volume = EG.roi.c_volume + value;

if (EG.roi.c_volume > size(EG.roi.I,4))
    EG.roi.c_volume = 1;
elseif (EG.roi.c_volume < 1)
    EG.roi.c_volume = size(EG.roi.I,4);
end

EG = mgui_roi_update_panel(EG, 0, 1);

end


% ------------------------------------------------------------
function EG = mgui_roi_analysis_play(EG)

tic;
EG = mgui_roi_update_panel(EG, 0, 1);
t_update = max(toc * 2, 0.2);

t = timer;
t.TimerFcn = @mgui_roi_analysis_play_next;
t.Period = round(t_update * 1e3) / 1e3;
t.ExecutionMode = 'FixedRate';
t.Name = EG.t_ROI_ANALYSIS_TIMER;
t.Tag = EG.t_ROI_ANALYSIS_TIMER;
start(t);

end

function EG = mgui_roi_analysis_stop(EG)

h = timerfind('Tag', EG.t_ROI_ANALYSIS_TIMER);
for c = 1:numel(h)
    stop(h(c));
    pause(0.01);
    delete(h(c));
end

end

function a = mgui_roi_analysis_play_next(a,b) %#ok<INUSD>

disp(num2str(rem(now,1),10))

h_fig = mgui_misc_get_mgui_fig();

EG = get(h_fig, 'UserData');
EG.roi.c_volume = EG.roi.c_volume + 1;
if (EG.roi.c_volume > size(EG.roi.I,4))
    EG.roi.c_volume = 1;
end
EG = mgui_roi_update_panel(EG, 0, 1);
set(h_fig, 'UserData', EG);

end





function EG = mgui_roi_analysis_plot(EG, hSender)

p = get(get(hSender, 'Parent'),'CurrentPoint');

EG.roi.c_volume = size(EG.roi.I,4) - round(p(1,2)) + 1;
if (EG.roi.c_volume > size(EG.roi.I,4))
    EG.roi.c_volume = size(EG.roi.I,4);
elseif (EG.roi.c_volume < 1)
    EG.roi.c_volume = 1;
end
EG = mgui_roi_update_panel(EG, 0, 1);


end


function mgui_roi_draw(varargin) % MOTION

% Get userdata and current point from sender
hSender = varargin{1};
h = get(hSender, 'CurrentAxes');
c = get(h, 'CurrentPoint');
s = get(h, 'UserData');

% First time here?
if (~isstruct(s)) 
    clear s; 
    s.p = [];
    
    % Retrieve the large EG struct as few time as possible, save as little
    % as possible in s
    EG = get(hSender,'UserData');
    s.col = EG.conf.roi_col;

    
    if (~isfield(EG.data,'roi'))
        s.is_landmark = 0;
    elseif (...
            (isfield(EG.data,'roi')) && ...
            (numel(EG.select.c_roi) > 0) && ...
            (isfield(EG.data.roi{EG.select.c_roi},'is_landmark')) && ...
            (EG.data.roi{EG.select.c_roi}.is_landmark))
        s.is_landmark = 1;
    else
        s.is_landmark = 0;
    end
    
end

% Landmarks are 1 voxel ROIs
if (~s.is_landmark)
    s.p = [s.p; c(1,1:2)];
else
    s.p = repmat(floor(c(1,1:2)),5,1) - [0 0; 0 1; 1 1; 1 0; 0 0] + 0.5;
end

if (size(s.p,1) > 1)
    h_line = findobj(get(h, 'Children'), 'Tag', 'mgui_ROI_LINE');
    
    if (numel(h_line) == 0)
                
        line(s.p(:,1), s.p(:,2), ...
            'Color', s.col, ...
            'LineWidth', 2, ...
            'Tag', 'mgui_ROI_LINE', ...
            'parent', h);
    else
        set(h_line, 'XData', s.p(:,1), 'YData', s.p(:,2));
    end
end

set(h,'UserData', s);

end


function mgui_roi_draw_stop(varargin) % UP

% Clear motion functions
h_fig = mgui_misc_get_mgui_fig();
if (~ishandle(h_fig)), return; end
set(h_fig,'WindowButtonMotionFcn', []);
set(h_fig,'WindowButtonUp', []);

% Get the caxis of current axes, then clear senders userdata
hSender = varargin{1};
h = get(hSender, 'CurrentAxes');
s = get(h,'UserData');
set(h, 'UserData', []);

if (isstruct(s) && isfield(s,'p'))
    p = s.p;
else
    return;
end

if (size(p,1) > 2)
    p = [p; p(1,:)];
    line(p(end-1:end,1), p(end-1:end,2), 'Color', s.col);
else
    return;
end


% Update GUI
EG = get(h_fig, 'UserData');

switch (EG.roi.c_dim)
    case 1
        I_roi = poly2mask(p(:,1), p(:,2), size(EG.roi.I,3), size(EG.roi.I,2));
    case 2
        I_roi = poly2mask(p(:,1), p(:,2), size(EG.roi.I,3), size(EG.roi.I,1));
    case 3
        I_roi = poly2mask(p(:,1), p(:,2), size(EG.roi.I,2), size(EG.roi.I,1));
end

if (~s.is_landmark)
    if (EG.roi.function == 1)
        val = 1;
    elseif (EG.roi.function == 2)
        val = -1;
    else
        error('strange value of EG.roi.functon');
    end
else
    % Clear last ROI
    val = 2;
end

EG = mgui_roi_add_roi(EG, val, I_roi);
set(h_fig, 'UserData', EG);

end





