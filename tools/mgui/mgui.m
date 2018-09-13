function mgui(varargin)
% function mgui(varargin)

h_fig = mgui_misc_get_mgui_fig();

% Init the figure
if (ishandle(h_fig)) % is GUI already running
    EG = get(h_fig, 'UserData');
    
    if (isempty(EG)), return; end % avoid errors while loading
    
    % Reset callback
    if (isempty(get(EG.tags.(EG.t_FIG), 'KeyPressFcn')))
        set(EG.tags.(EG.t_FIG),'KeyPressFcn', EG.f_callback);
    end       
        
else
    
    % This is where the init needs to take place
    EG = mgui_define_tags;
    EG.conf.is_gui = 1;
    
    % Pull in external data
    if (nargin > 0) && (isstruct(varargin{1}))
        EG.data = varargin{1}.data;
    end
    
    % c_mode: 2 - browse, 3 - roi-based
    if (nargin > 1) && (isnumeric(varargin{2}))
        c_mode = varargin{2};
    else
        c_mode = 2;
    end
    

    % Just make sure this structure is here
    EG.handles.defined = 1;

    EG = mgui_create_figure(EG);
    EG = mgui_setup_figure(EG, c_mode);
    EG = mgui_gui_browse_mode(EG);
    
    % Setup tags for later use
    f = fieldnames(EG);
    tags = {};
    for c = 1:numel(f)
        if (iscell(EG.(f{c}))), continue; end
        if (all(f{c}(1:2) == 't_'))
            tags{end+1} = EG.(f{c}); %#ok<AGROW>
        end
    end
    
    EG.tags = mgui_misc_tags_update(EG.tags, tags);

    % At high resolution displays, set the font size a bit higher
    set(0, 'DefaultTextFontSize', EG.conf.default_font_size);
    
end

% Handle input arguments

if (nargin >= 1)
    
    t_start = tic;
    
    % Store handle of sender
    if (ishandle(varargin{1}))
        EG.hSender = varargin{1};
    else
        EG.hSender = [];
    end
    
    mgui_save = EG;
    try
        
        % Handle keystrokes
        if (numel(varargin) >= 2)
            event_info = varargin{2};
            if (msf_isfield(event_info, 'Key'))
                EG = mgui_roi_gui_callback([],event_info);
            end
        end
        
        % Handle button presses and similar stuff
        if (ishandle(EG.hSender))
            
            switch (get(EG.hSender, 'Tag'))
                    
                case EG.t_BROWSE_FILE
                    EG = mgui_browse_file(EG);
                    
                case EG.t_BROWSE_FOLDER
                    EG = mgui_browse_folder(EG);
                    
                case EG.t_BROWSE_EXT
                    EG = mgui_browse_update_panel(EG);
                    
                case EG.t_BROWSE_ROI
                    EG = mgui_browse_file(EG);
                    
            end
        end
        
    catch me
        disp(getReport(me,'Extended'));
        
        if (EG.conf.do_rethrow_error)
            rethrow(me);
        else
            uiwait(msgbox(me.message, 'Error occured', 'modal'));
        end
        
        EG = mgui_save;
    end
    
    % Display info
    disp(['Action took ' num2str(toc(t_start))]);
    
    % Remove sender handle to avoid confusion
    EG.hSender = [];
end

% Finally, save the handles for next round
set(EG.handles.h_fig, 'UserData', EG);


end


% -------------------------------------------------------------------------
function EG = mgui_browse_file(EG)

EG.browse.c_item = get(EG.tags.(EG.t_BROWSE_FILE), 'Value');
EG.browse.c_roi  = get(EG.tags.(EG.t_BROWSE_ROI), 'Value');

if (EG.browse.d(EG.browse.c_item).isdir)
    
    EG.browse.path = EG.browse.d(EG.browse.c_item).fullfile;
    EG = mgui_browse_update_panel(EG);    
    
else    
    
    % Switch off all panels, load data and update panels
    EG.browse.filename = EG.browse.d(EG.browse.c_item).fullfile;
    EG = mgui_function_change(EG); 
    colormap gray;
end

end

% -------------------------------------------------------------------------
function EG = mgui_browse_folder(EG)

path = uigetdir(EG.browse.path);

if (path == 0), return; end

EG.browse.path = path;
EG = mgui_browse_update_panel(EG);

end


% ------------------------------------------------------------------------
function EG = mgui_gui_browse_mode(EG, browse_path)

if (nargin < 2), browse_path = pwd; end

EG.browse.path = browse_path;
EG = mgui_browse_update_panel(EG);

end



