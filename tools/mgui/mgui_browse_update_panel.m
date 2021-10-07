function EG = mgui_browse_update_panel(EG)
% function EG = mgui_browse_update_panel(EG)

% Remove trailing filesep in path
if (~isempty(EG.browse.path)) && (EG.browse.path(end) == filesep)
    EG.browse.path = EG.browse.path(1:(end-1));
end

EG.browse.ext = {};
EG = mgui_browse_add_ext(EG, 'nii');
EG = mgui_browse_add_ext(EG, 'mif');
EG = mgui_browse_add_ext(EG, inf);

if (isempty(EG.browse.path))
    EG.browse.path = '/';
end

d_all = dir(EG.browse.path);

if (isempty(d_all))
    EG.browse.path = '~';
    d_all = dir(EG.browse.path);
end

switch (EG.c_mode)
    
    case 2 % default
        
        % First, add parent
        d = d_all(2);
        d.isdir = 1;
        d.fullfile = EG.browse.path(1:find(EG.browse.path == filesep, 1, 'last'));
        d.name = ['.. (' d.fullfile ')'];
        d_out = d;
        
        % Second, add folders
        for c = 1:numel(d_all)
            d = d_all(c);
            if ((d.isdir) && (d.name(1) ~= '.'))
                d.fullfile = fullfile(EG.browse.path, d.name);
                d.name = fullfile(d.name, filesep);
                d_out(end+1) = d; %#ok<AGROW>
            end
        end
        
        % Third, add the files
        c_ext = get(findobj('Tag', EG.t_BROWSE_EXT), 'value');
        d_all = dir(EG.browse.path);
        for c = 1:numel(d_all)
            d = d_all(c);
            if (d.isdir), continue; end
            
            % Filter out files with correct extension
            [~,filename,ext] = fileparts(d.name);
            
            if ( (~isempty(filename)) && (filename(1) == '.') ), continue; end
            
            if (strcmpi(ext,'.gz')), [~,~,ext] = fileparts(filename); end
            
            ext_ref = EG.browse.ext{c_ext}.ext;
            if (numel(ext_ref) > 0) && (~strcmpi(ext, ext_ref)), continue; end
            
            d.fullfile = fullfile(EG.browse.path, d.name);
            d_out(end+1) = d; %#ok<AGROW>
        end
        
    case 3 % use a data ref structure
        
        for c = 1:numel(EG.data.ref)
            
            d = dir(EG.data.ref(c).fn);
            if (isempty(d)), continue; end
            d.fullfile = EG.data.ref(c).fn;
            
            d_out(c) = d; %#ok<AGROW>
            d_out(c).name = EG.data.ref(c).name; %#ok<AGROW>
            
        end
        
end

% Save to EG
EG.browse.d = d_out;

% Populate the select box
str = cell(1,numel(d_out));
for c = 1:numel(d_out)
    str{c} = d_out(c).name;
end

set(findobj('Tag', EG.t_BROWSE_FILE), 'Value', 1);
set(findobj('Tag', EG.t_BROWSE_FILE), 'String', str);

switch (EG.c_mode)
    
    case 2 % Work with extensions panel
        
        str = cell(1,numel(EG.browse.ext));
        for c = 1:numel(EG.browse.ext)
            str{c} = EG.browse.ext{c}.name;
        end
        
        set(findobj('Tag', EG.t_BROWSE_EXT), 'String', str);
        set(findobj('Tag', EG.t_BROWSE_EXT), 'Value', c_ext);
    
    case 3 % Work with the ROI list
        
        str = EG.data.roi_list;
        
        set(findobj('Tag', EG.t_BROWSE_ROI), 'Value', 1);
        set(findobj('Tag', EG.t_BROWSE_ROI), 'String', str);
        
end


