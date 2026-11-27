function EG = mgui_clipboard_copy_roi(EG)
%   EG = mgui_clipboard_copy_roi(EG) copies the ROI defined in EG.roi.I_roi
%   to EG.clipboard.I_roi. If no ROI exists, it displays a message.
%
%   Input:
%       EG: GUI data structure containing roi and clipboard fields.
%   Output:
%       EG: Updated GUI data structure.

    if isfield(EG.roi, 'I_roi')
        EG.clipboard.operation = 'copy';
        EG.clipboard.I_roi = EG.roi.I_roi;
        disp('ROI copied to clipboard.');
    else
        disp('No ROI to copy.');
    end
end
