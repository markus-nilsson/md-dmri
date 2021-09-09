function msf_mkdir(folder_path)
% function msf_mkdir(folder_path)
%
% Recursively makes folder_path

if (isempty(folder_path)), return; end

if (isunix)
    
    try
        eval(['!mkdir -p "' folder_path '"']);
    catch 
        disp('could not make directory');
    end
    
else
    
    [status, ~, ~] = mkdir(folder_path);
    
    if (~status)
        error('Could not make directory');
    end
    
end