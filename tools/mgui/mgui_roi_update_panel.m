function EG = mgui_roi_update_panel(EG, do_reload, do_redraw_image)
% function EG = mgui_roi_update_panel(EG, do_reload, do_redraw_image)

if (nargin < 2), do_reload = 0; end
if (nargin < 3), do_redraw_image = 0; end

% Ensure fields are present
EG.data.present = 1;
EG.roi.present = 1;

% Always ensure that reference field is set for linking to gui_volume
f_update_panel = @(l_EG)(mgui_roi_update_panel(l_EG, 0, 1));
EG.roi.ref = mgui_gui_volume_create_ref(EG.roi_volume_tags, 'roi', 'I', ...
    f_update_panel);

% Load image
if (do_reload)
    
    % Save old EG.roi structure
    mgui_roi_old = EG.roi;
    
    % Load the image volume and get the filename
    EG = mgui_waitbar(EG, 0.1, 'Loading...');
    try
        [I, header, filename, ext, xps, xps_fn] = mgui_contrast_load(EG);
    catch me
        disp(getReport(me,'Extended'));
        return;
    end
    
    % Read image to display
    if ((numel(filename) == 0) || (numel(I) == 0))
        EG.roi = msf_rmfield(EG.roi, {'I', 'I_roi', 'xps'});
    else
        EG.roi.I      = I;
        EG.roi.header = header;
        EG.roi.ext    = ext;
        EG.roi.I_max  = max(I(:));
        EG.roi.xps    = xps;
        EG.roi.xps_fn = xps_fn;
    end
    
    % Reset zoom in case of change in size
    sz = size(I);
    if (isfield(EG.roi, 'I_sz') && ...
            (numel(sz) ~= numel(EG.roi.I_sz) || any(size(I) ~= EG.roi.I_sz)))
        EG.roi = my_rmfield(EG.roi, 'zoom');
    end
    EG.roi.I_sz = size(I);
    
    % Set standard color, but...
    EG.roi.col = EG.conf.roi_col;
    EG.roi.is_equal_dim = 1;
    
    % Switch off undo button
    set(EG.tags.(EG.t_ROI_UNDO), 'Enable', 'off');
    
    % Look for ROI files and load them
    EG = mgui_waitbar(EG, 0.4, 'Loading ROIs...');
    EG.roi.is_updated = 1;
    
    if ...
            (EG.c_mode == 2) && ... % Browse mode
            (isfield(mgui_roi_old,'I')) && ...
            (isfield(mgui_roi_old,'I_roi')) && ...
            (isfield(EG.roi,'I')) && ...
            (ndims(mgui_roi_old.I) >= 3) && (ndims(EG.roi.I) >= 3) && ...
            (size(mgui_roi_old.I,1) == size(EG.roi.I,1)) && ...
            (size(mgui_roi_old.I,2) == size(EG.roi.I,2)) && ...
            (size(mgui_roi_old.I,3) == size(EG.roi.I,3))
        
        % If we are in browse mode, use the old ROI if adequate
        EG.roi.I_roi = mgui_roi_old.I_roi;
    else
        % Clear the ROI
        EG.roi.I_roi = mgui_roi_empty(EG);
    end
    
    EG.roi.n_voxels = sum(EG.roi.I_roi(:)); % save time, reuse this
    
    
    % --- UPDATE POSITION IN STACK --- START ---
    
    % Look at where the action is coming from in order to determine how
    % to update the view
    slice_mode = 'centre_on_roi';
    
    if (isfield(EG.conf, 'slice_mode')), slice_mode = EG.conf.slice_mode; end
    
    % Prepare slice_mode
    switch (slice_mode)
        
        case 'centre_on_roi'
            
            % Cannot use centre_on_roi unless there is a ROI defined
            if (~isfield(EG.roi,'I_roi')) || (EG.roi.n_voxels == 0)
                slice_mode = 'retain_slice';
            end
    end
    
    % Execute position update
    switch (slice_mode)
        
        case 'centre_on_roi'
            
            % We know ROI is present from check above
            EG.roi.c_slice_save = mgui_misc_roi_centre(EG.roi.I_roi);
            
            % Set dimension
            EG.roi.c_dim = mgui_misc_roi_dim(EG.roi.I_roi, EG.roi.n_voxels);
            
            % For DS
            if (isfield(mgui_roi_old,'c_dim'))
                EG.roi.c_dim = mgui_roi_old.c_dim;
            end
            
        case 'retain_slice'
            
            % Stay in same slice, if possible
            if (isfield(mgui_roi_old, 'c_slice_save'))
                
                if (all(mgui_roi_old.c_slice_save == 1))
                    
                    % This happens when we're passing through a
                    % non-existing contrast
                    EG.roi = my_rmfield(EG.roi, 'c_slice_save');
                    
                elseif ((~isfield(EG.roi,'I')) || (~isfield(mgui_roi_old,'I')))
                    
                    % Try at least to keep the slice position intact
                    EG.roi.c_slice_save = mgui_roi_old.c_slice_save;
                    
                elseif (numel(mgui_roi_old.c_slice_save) > 0)
                    
                    % Recalculate slice into new volume
                    I_dim = size(EG.roi.I);
                    I_dim_old = size(mgui_roi_old.I);
                    
                    if (numel(I_dim) < 3), I_dim(3) = 1; end
                    if (numel(I_dim_old) < 3), I_dim_old(3) = 1; end
                    if (all(I_dim(1:3) == I_dim_old(1:3)))
                        EG.roi.c_slice_save = mgui_roi_old.c_slice_save;
                    else
                        EG.roi.c_slice_save = ceil(mgui_roi_old.c_slice_save(1:3) .* ...
                            (I_dim(1:3) ./ I_dim_old(1:3)));
                    end
                    
                else
                    EG.roi.c_slice_save = [];
                end
            end
            
            % ...and in same dim
            if (isfield(mgui_roi_old,'c_dim'))
                EG.roi.c_dim = mgui_roi_old.c_dim;
            end
            
            % ...and in same volume
            if (isfield(mgui_roi_old,'c_volume'))
                EG.roi.c_volume = mgui_roi_old.c_volume;
            end
            
            
        otherwise
            EG.roi = my_rmfield(EG.roi, 'c_slice_save');
            EG.roi = my_rmfield(EG.roi, 'c_dim');
            
    end
    
    % Reset zoom and pan (could be handled better later)
    if (~isfield(EG.roi, 'zoom') || ~isfield(EG.roi.zoom,'factor'))
        EG.roi.zoom.factor = ones(1,3);
        EG.roi.zoom.origin = {NaN, NaN, NaN};
    else
        try
            for c_dim = 1:3
                
                a = [size(EG.roi.I) 1];
                a = a( (1:3) ~= c_dim );
                
                if (...
                        any(EG.roi.zoom.origin{c_dim} < [1 1]) || ...
                        any(EG.roi.zoom.origin{c_dim} >   a  ))
                    
                    EG.roi.zoom.origin{c_dim} = a/2;
                    
                end
            end
        catch me
            disp(me.message);
        end
    end
    
    % --- UPDATE POSITION IN STACK --- STOP ---
    
    
    
    % --- ERROR CHECKS --- START ---
    
    % Make sure selected slice is OK, otherwise, centre on stack
    if (...
            (~isfield(EG.roi,'c_slice_save')) || ...
            (numel(EG.roi.c_slice_save) == 0) || ...
            (any(EG.roi.c_slice_save < 0)))
        
        if (isfield(EG.roi, 'I'))
            EG.roi.c_slice_save = round(size(EG.roi.I) / 2);
        else
            EG.roi.c_slice_save = [1 1 1];
        end
        
    end
    
    % Ensure a dimension is selected
    if (...
            (~isfield(EG.roi,'c_dim')) || ...
            (numel(EG.roi.c_dim) == 0))
        EG.roi.c_dim = 3;
    end
    
    % Ensure volume counter exists
    if ((~isfield(EG.roi,'c_volume')) || (numel(EG.roi.c_volume) == 0))
        EG.roi.c_volume = 1;
    end
    
    % Error check on volume counter
    if (isfield(EG.roi,'I'))
        if (EG.roi.c_volume > size(EG.roi.I,4))
            EG.roi.c_volume = 1;
        end
        
        if (numel(EG.roi.c_volume) == 0)
            EG.roi.c_volume = 1;
        end
    end
    
    % --- ERROR CHECKS --- STOP ---
    
    % Finally, simulate a click, will call do_redraw_image below
    if (numel(EG.roi.c_slice_save) >= EG.roi.c_dim)
        EG.roi.c_slice = EG.roi.c_slice_save(EG.roi.c_dim);
    else
        EG.roi.c_slice = 1;
    end
    EG = mgui_gui_set_dim(EG, EG.roi.ref, EG.roi.c_dim);
    
    % Set functions to default values
    EG = mgui_roi_set_function(EG, 1);
    
end

if (do_redraw_image)
    
    % we need to recalculate this quite often since the ROI can be changed
    % in quite some different ways -- or, identify these and make the code
    % quicker that way
    EG.roi.n_voxels = sum(EG.roi.I_roi(:)); % save time, reuse this
    
    % XXX: Tmp, slice_save strangely used, should be incorporated
    % somewhere, maybe here?
    EG.roi.c_slice_save(EG.roi.c_dim) = EG.roi.c_slice;
    
    
    % Update the caxis on display
    [EG, this_caxis] = mgui_roi_caxis(EG, EG.roi.c_volume); 
    
    set(EG.tags.(EG.t_ROI_WINDOW_MIN), 'String', num2str(this_caxis(1), 3));
    set(EG.tags.(EG.t_ROI_WINDOW_MAX), 'String', num2str(this_caxis(2), 3));

    % Update volume number
    set(EG.tags.(EG.t_ROI_ANALYSIS_CVOL), 'String', sprintf('%i/%i', EG.roi.c_volume, size(EG.roi.I,4)));

    
    
    EG = mgui_waitbar(EG, 0.6, 'Drawing image');
    
    
    % Ensure that zoom struct is apprpriately formatted
    if (~isfield(EG.roi,'zoom') || ~isstruct(EG.roi.zoom))
        EG.roi.zoom.factor = ones(1,3);
        EG.roi.zoom.origin = {NaN, NaN, NaN};
    end
    
    % List of handles, tags, dims, slices, zoom factors and zoom origins
    h_list = [EG.handles.h_roi_axes EG.handles.h_roi_zoom];
    t_list = {EG.t_ROI_IMAGE, EG.t_ROI_ZOOM_IMAGE{:}}; %#ok<CCAT>
    d_list = [EG.roi.c_dim 1 2 3];
    s_list = [EG.roi.c_slice EG.roi.c_slice_save];
    z_list = [EG.roi.zoom.factor(EG.roi.c_dim) 1 1 1];
    o_list = {EG.roi.zoom.origin{EG.roi.c_dim}, NaN, NaN, NaN};
    
    % Ensure current slice is shown in zoom-plot panel
    s_list(EG.roi.c_dim+1) = EG.roi.c_slice;
    
    % Avoid redrawing the zoom-plots if they are not shown
    if (strcmp(get(EG.tags.(EG.t_ROI_ZOOM_PANEL),'visible'),'on'))
        n_imagesc = 4;
    else
        n_imagesc = 1;
    end
    
    % Loop over the various parts of the GUI
    for c = 1:n_imagesc
        
        % Select handle and prepare figure
        h = h_list(c);
        
        % Remove plot elements
        h_child = findobj(get(h,'Children'), ...
            'Type', 'Image', '-xor');
        delete(h_child);
        
        % Load the image
        if (isfield(EG.roi,'I'))
            
            [I,ar,c_slice_eff] = mgui_misc_format_image(EG, EG.roi.I, ...
                s_list(c), d_list(c), EG.roi.header, EG.roi.c_volume);

            
            % Show template instead of original
            if (isfield(EG.roi,'I_template') && (~isempty(EG.roi.I_template)))
                if (ndims(EG.roi.I_template) ~= ndims(EG.roi.I)) || ...
                        (any(size(EG.roi.I_template) ~= size(EG.roi.I)))
                    EG.roi = rmfield(EG.roi, 'I_template');
                end
            end
            
            if (isfield(EG.roi,'I_template') && (~isempty(EG.roi.I_template)))
                
                % fast implementation
                [I_tmp] = mgui_misc_format_image(EG, EG.roi.I_template, ...
                    s_list(c), d_list(c), EG.roi.header, EG.roi.c_volume);
                
                I = I_tmp / nanmax(I_tmp(:)) * nanmax(I(:));
                
            end
        else
            cla(h);
            imagesc(0,'Parent', h);
            axis(h,'off');
            continue;
        end
        
        % Deal with complex images
        if (any(~isreal(I)))
            I_display = single(abs(I));
        else
            I_display = single(I);
        end
        
        % Display current image
        h_image = findobj(get(h, 'Children'), 'Type', 'Image');
        if (isempty(h_image))
            h_image = imagesc(I_display, 'parent', h);
        else
            if (numel(h_image) > 1)
                disp('strange!');
                delete(h_image(2:end));
                h_image = h_image(1);
            end
            
            set(h_image, 'CData', I_display, 'parent', h);
        end
        
        % Clear the temporary display iamge
        clear I_display;
        
        
        set(h_image,...
            'Tag', t_list{c}, ...
            'ButtonDownFcn', EG.f_roi_gui_callback);
        set(h, 'xtick', [], 'ytick', []);
        
        
        caxis(h, this_caxis(1:2));
        set  (h, 'DataAspectRatio', [ar([2 1]) 1]);
        
        % Initialize zoom origin if required; feed that back to EG-struct
        if (isnan(o_list{c}))
            o_list{c} = [size(I,2) size(I,1)] / 2;
        end
        
        % Adjust axis in order to zoom
        ax  = [ [-1 1] * size(I,2)/2 [-1 1] * size(I,1)/2] / z_list(c);
        ax  = ax + o_list{c}([1 1 2 2]) + 0.5;
        axis(h, ax);
        
        % In first loop, save things for later use
        if (c == 1)
            ax0 = ax;
            c_slice_eff0 = c_slice_eff;
            EG.roi.zoom.origin{EG.roi.c_dim} = o_list{c};
        end
        
        % Add extra plots
        hold(h, 'on');
        
        
        % Show ROI and add text
        if (c == 1)

            if (isfield(EG.roi,'I_roi'))

                EG = mgui_waitbar(EG, 0.8, 'Plotting ROI');
                
                plot_roi(mgui_misc_format_image(EG, EG.roi.I_roi, EG.roi.c_slice, ...
                    EG.roi.c_dim), EG.roi.col, 2, 1, h);
                
                hold(EG.handles.h_roi_axes, 'on');
                
            end
        end
        
        % Show zoomed in area or slice-lines
        c_proj = {[0 0 0], [0 1 2], [1 0 2], [1 2 0]};
        h_plot = [];
        if (c > 1) && (d_list(c) == EG.roi.c_dim)
            h_plot = plot(h, ...
                ax0([1 2 2 1 1]), ...
                ax0([3 3 4 4 3]), 'b');
            set(h_plot, 'Tag', 'mgui_ROI_ZOOM_PLOT', 'LineWidth', 2);
        elseif (c_proj{c}(EG.roi.c_dim) == 1)
            h_plot = plot(h, [0 0] + c_slice_eff0, [0 size(I,1)] + 0.5, 'b', 'color', 'white', 'linewidth', 2);
            text(c_slice_eff0, 0.05 * size(I,2), ...
                [' ' num2str(c_slice_eff0)], 'Parent', h, 'color', 'white');
            set(h_plot, 'Tag', 'mgui_ROI_PROJ_Y_PLOT');
        elseif (c_proj{c}(EG.roi.c_dim) == 2)
            h_plot = plot(h, [0 size(I,2)] + 0.5, [0 0] + size(I,1) + 1 - c_slice_eff0, 'b', 'color', 'white', 'linewidth', 2);
            text(2, size(I,1) - 4 - c_slice_eff0, ...
                [' ' num2str(c_slice_eff0)], 'Parent', h, 'color', 'white');
            set(h_plot, 'Tag', 'mgui_ROI_PROJ_X_PLOT');
        end
        set(h_plot, 'HitTest', 'off');
        
    end
    
    colormap(gray);    

    if (EG.roi.is_updated)
        EG.analysis.present = 1;
        EG.analysis = msf_rmfield(EG.analysis, 'S');
        EG = mgui_analysis_update_panel(EG);
    end
    
    
    
    % this should probably not go here, but...
    EG.roi.is_updated = 0;
    
end

