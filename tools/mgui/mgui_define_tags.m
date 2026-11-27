function EG = mgui_define_tags(EG)
% function EG = mgui_define_tags(EG)

if (nargin < 1), 
    EG = []; 
end

EG.conf.default_font_size = 11;
EG.conf.do_rethrow_error  = 0;
EG.conf.disable_waitbar   = 1;
EG.conf.ori               = 'LAS';
EG.conf.roi_col           = 'r';
EG.conf.version_str       = '0.1';

EG.hSender = [];

% Callbacks
EG.f_callback               = @mgui;
EG.f_roi_gui_callback       = @mgui_roi_gui_callback;


% Other fields that must be present
EG.study_path = '';

EG.tags.present = 1;

EG.t_FIG = 'mgui_FIG';

EG.t_DATA_PANEL             = 'mgui_DATA_PANEL';
EG.t_ROI_PANEL              = 'mgui_ROI_PANEL';


% SELECT PANEL
EG.t_SELECT_LOAD            = 'mgui_SELECT_LOAD';
EG.t_SELECT_RELOAD          = 'mgui_SELECT_RELOAD';
EG.t_SELECT_GROUP           = 'mgui_SELECT_GROUP';
EG.t_SELECT_SUBJECT         = 'mgui_SELECT_SUBJECT';
EG.t_SELECT_EXAM            = 'mgui_SELECT_EXAM';
EG.t_SELECT_SET             = 'mgui_SELECT_SET';
EG.t_SELECT_CONTRAST        = 'mgui_SELECT_CONTRAST';
EG.t_SELECT_SWITCH          = 'mgui_SELECT_SWITCH';
EG.t_SELECT_ROI             = 'mgui_SELECT_ROI';
EG.t_SELECT_TRK             = 'mgui_SELECT_TRK';

% BROWSER PANEL
EG.t_BROWSE_FILE           = 'mgui_BROWSER_FILE';
EG.t_BROWSE_ROI            = 'mgui_BROWSER_ROI';
EG.t_BROWSE_FOLDER         = 'mgui_BROWSER_FOLDER';
EG.t_BROWSE_EXT            = 'mgui_BROWSER_EXT';

% ROI PANEL
EG.t_ROI_AXES               = 'mgui_ROI_AXES';
EG.t_ROI_HIST_AXES          = 'mgui_ROI_HIST_AXES';
EG.t_ROI_INFO_AXES          = 'mgui_ROI_INFO_AXES';
EG.t_ROI_SLICE_PLUS         = 'mgui_ROI_SLICE_PLUS';
EG.t_ROI_SLICE_MINUS        = 'mgui_ROI_SLICE_MINUS';
EG.t_ROI_SLICE_SLIDER       = 'mgui_ROI_SLICE_SLIDER';
EG.t_ROI_TRA                = 'mgui_ROI_TRA';
EG.t_ROI_SAG                = 'mgui_ROI_SAG';
EG.t_ROI_COR                = 'mgui_ROI_COR';
EG.t_ROI_PLUS               = 'mgui_ROI_PLUS';
EG.t_ROI_MINUS              = 'mgui_ROI_MINUS';
EG.t_ROI_WINDOW             = 'mgui_ROI_WINDOW';
EG.t_ROI_CLEAR              = 'mgui_ROI_CLEAR';
EG.t_ROI_UNDO               = 'mgui_ROI_UNDO';
EG.t_ROI_COPY               = 'mgui_ROI_COPY';
EG.t_ROI_PASTE              = 'mgui_ROI_PASTE';
EG.t_ROI_AUTO               = 'mgui_ROI_AUTO';
EG.t_ROI_WINDOW_MIN         = 'mgui_WINDOW_MIN';
EG.t_ROI_WINDOW_MAX         = 'mgui_WINDOW_MAX';
EG.t_ROI_WINDOW_AUTO        = 'mgui_WINDOW_AUTO';
EG.t_ROI_IMAGE              = 'mgui_ROI_IMAGE';
EG.t_ROI_ZOOM_AXES_TRA      = 'mgui_ROI_ZOOM_AXES_TRA';
EG.t_ROI_ZOOM_AXES_COR      = 'mgui_ROI_ZOOM_AXES_COR';
EG.t_ROI_ZOOM_AXES_SAG      = 'mgui_ROI_ZOOM_AXES_SAG';
EG.t_ROI_ZOOM_IMAGE_TRA     = 'mgui_ROI_ZOOM_IMAGE_TRA';
EG.t_ROI_ZOOM_IMAGE_COR     = 'mgui_ROI_ZOOM_IMAGE_COR';
EG.t_ROI_ZOOM_IMAGE_SAG     = 'mgui_ROI_ZOOM_IMAGE_SAG';
EG.t_ROI_ZOOM_PLUS          = 'mgui_ROI_ZOOM_PLUS';
EG.t_ROI_ZOOM_MINUS         = 'mgui_ROI_ZOOM_MINUS';
EG.t_ROI_ZOOM_PANEL         = 'mgui_ROI_ZOOM_PANEL';

EG.t_ROI_ZOOM_AXES          = {EG.t_ROI_ZOOM_AXES_TRA,  EG.t_ROI_ZOOM_AXES_COR,  EG.t_ROI_ZOOM_AXES_SAG};
EG.t_ROI_ZOOM_IMAGE         = {EG.t_ROI_ZOOM_IMAGE_TRA, EG.t_ROI_ZOOM_IMAGE_COR, EG.t_ROI_ZOOM_IMAGE_SAG};

EG.t_ROI_ENABLE_OVERVIEW    = 'mgui_ROI_ENABLE_OVERVIEW';
EG.t_ROI_ENABLE_ANALYSIS    = 'mgui_ROI_ENABLE_ANALYSIS';
EG.t_ROI_ANALYSIS_AXES      = 'mgui_ROI_ANALYSIS_AXES';
EG.t_ROI_ANALYSIS_PANEL     = 'mgui_ROI_ANALYSIS_PANEL';

EG.t_ROI_ANALYSIS_CVOL      = 'mgui_ROI_ANALYSIS_CVOL';
EG.t_ROI_ANALYSIS_PLUS      = 'mgui_ROI_ANALYSIS_PLUS';
EG.t_ROI_ANALYSIS_MINUS     = 'mgui_ROI_ANALYSIS_MINUS';
EG.t_ROI_ANALYSIS_PLAY      = 'mgui_ROI_ANALYSIS_PLAY';
EG.t_ROI_ANALYSIS_STOP      = 'mgui_ROI_ANALYSIS_STOP';
EG.t_ROI_ANALYSIS_COPY      = 'mgui_ROI_ANALYSIS_COPY';
EG.t_ROI_ANALYSIS_TIMER     = 'mgui_ROI_ANALYSIS_TIMER';
EG.t_ROI_ANALYSIS_PLOT      = 'mgui_ROI_ANALYSIS_PLOT';


% ANALYSIS
EG.t_ANALYSIS_PANEL         = 'mgui_ANALYSIS_PANEL';
EG.t_ANALYSIS_POPUP         = 'mgui_ANALYSIS_POPUP';
EG.t_ANALYSIS_REDO_BUTTON   = 'mgui_ANALYSIS_REDO_BUTTOM';


