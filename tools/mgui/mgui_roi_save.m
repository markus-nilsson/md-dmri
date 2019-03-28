function EG = mgui_roi_save(EG)
% function EG = mgui_roi_save(EG)

% Make sure all relevant fields are present
if (~isfield(EG, 'roi')) || ...
         (~isfield(EG.roi,'I_roi')) || ...
         (~isfield(EG.roi,'is_updated')) || ...
         (~isfield(EG.roi,'roi_filename'))
     error('ROI definitions are wrong'); 
end

% This is part of the GUI logic: do not save unless an ROI is open, 
% updated, and present
if (isempty(EG.roi.roi_filename)), return; end
if (~EG.roi.is_updated), return; end
if (numel(EG.roi.I_roi(:)) <= 1), return; end

% Use header of currently loaded image
h = EG.roi.header;

% Flip ROI volume
I_roi = mgui_misc_flip_volume(EG.roi.I_roi, EG.conf.ori, mdm_nii_oricode(h));

% Save as nifti: Important to use EG.roi.roi_filename here
msf_mkdir(msf_fileparts(EG.roi.roi_filename));
mdm_nii_write(single(I_roi), EG.roi.roi_filename, h);

