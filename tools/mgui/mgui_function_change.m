function EG = mgui_function_change(EG, varargin)
% function EG = mgui_function_change(EG)
%

% Save ROI, but then remove fields to prevent crosstalks 
%
% ROI should also be removed, otherwise, ROIs may get overwritten, however,
% this cause troubles with slice positions not being remembered...

if (EG.c_mode == 3)
    EG = mgui_roi_save(EG);
end

if (isfield(EG, 'roi'))
    
    clear r;
    f_list = {'c_slice_save', 'c_dim', 'c_volume', 'c_slice', 'I', 'I_roi'};
        
    r = [];
    for f = f_list
        try
            r.(f{1}) = EG.roi.(f{1});
        catch me
            disp(me.message);
        end
    end
    
    EG = msf_rmfield(EG, 'roi'); % XXX: save some info from this later on
    
    EG.roi = r;
end

EG = msf_rmfield(EG,'analysis');

% Update content
EG = mgui_update_panel(EG);

