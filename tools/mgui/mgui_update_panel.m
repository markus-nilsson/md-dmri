function EG = mgui_update_panel(EG)
% function EG = mgui_update_panel(EG)
% -------------------------------------------------------------------------

% Update the visible panel, but show waitbar conditionally
EG = mgui_waitbar(EG, 0, 'Loading...'); 
EG = mgui_roi_update_panel(EG, 1, 1);
EG = mgui_analysis_update_panel(EG); 

EG = mgui_waitbar(EG, inf, '');

end

