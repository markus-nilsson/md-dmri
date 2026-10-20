function mgui_close(varargin)
% function mgui_close(varargin)

EG = mgui_define_tags;

if (ishandle(findobj('Tag',EG.t_FIG)))
    EG = get(findobj('Tag',EG.t_FIG), 'UserData');    
    clear EG;
end

close(gcf,'force');
%delete(gcf);

return;
