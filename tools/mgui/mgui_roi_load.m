function EG = mgui_roi_load(EG)
% function I_roi = mgui_roi_load(EG)

if (EG.c_mode ~= 3), return; end % only enabled for mode 3

if (~exist(EG.browse.filename, 'file')), return; end

roi_filename = EG.data.nii_fn_to_roi_fn(EG.browse.c_item, EG.browse.c_roi);

% Load the ROI if present
if (exist(roi_filename, 'file'))
    [I_roi, h] = mdm_nii_read(roi_filename);
    I_roi = mgui_misc_flip_volume(I_roi, mdm_nii_oricode(h), EG.conf.ori);
else
    I_roi = mgui_roi_empty(EG);
end

EG.roi.I_roi = double(I_roi);
EG.roi.roi_filename = roi_filename;