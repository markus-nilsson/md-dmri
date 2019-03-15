function EG = mgui_roi_save(EG)
% function EG = mgui_roi_save(EG)

if (~isfield(EG, 'roi')), return; end
if (~isfield(EG.roi,'I_roi')), return; end
if (numel(EG.roi.I_roi(:)) <= 1), return; end
if (EG.c_mode ~= 3), return; end % only enabled for mode 3

try
    if (~EG.roi.is_updated), return; end
catch
    return;
end

% important to use loaded roi filename here
roi_filename = EG.roi.roi_filename;

% Create the path
roi_path = msf_fileparts(roi_filename);
[~,~] = mkdir(roi_path);

% Get header of current document
h = EG.roi.header;

% Flip ROI volume
I_roi = mgui_misc_flip_volume(EG.roi.I_roi, EG.conf.ori, mdm_nii_oricode(h));

% Save as nifti
mdm_nii_write(uint8(I_roi), roi_filename, h);

