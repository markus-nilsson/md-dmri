function EG = mgui_clipboard_paste_roi(EG)
%   EG = mgui_clipboard_paste_roi(EG) pastes EG.clipboard.I_roi into EG.roi.I_roi
%   after checking for size compatibility and existence of both clipboard and current ROI.
%
%   Input:
%       EG: GUI data structure containing roi and clipboard fields.
%   Output:
%       EG: Updated GUI data structure.

    if isfield(EG, 'clipboard') && isfield(EG.clipboard, 'I_roi')
        if isfield(EG.roi, 'I_roi')
            if isequal(size(EG.roi.I_roi), size(EG.clipboard.I_roi))
                EG.roi.I_roi = EG.clipboard.I_roi;
                EG.roi.is_updated = 1;
                EG = mgui_roi_update_panel(EG, 0, 1);
                disp('ROI pasted.');
            else
                msgbox(sprintf('Clipboard ROI size (%s) does not match current ROI size (%s).', mat2str(size(EG.clipboard.I_roi)), mat2str(size(EG.roi.I_roi))));
            end
        else
            msgbox('No current ROI to paste into.');
        end
    else
        disp('Clipboard is empty.');
    end
end
