function [EG, this_caxis] = mgui_roi_caxis(EG, c_volume)
% function [EG, this_caxis] = mgui_roi_caxis(EG, c_volume)

if (nargin < 1), c_volume = 1; end

if (isfield(EG.roi, 'caxis'))
    this_caxis = EG.roi.caxis;
    return;
end

% Pull out the relevant image
if ((ndims(EG.roi.I) == 4) && (size(EG.roi.I,1) ~= 3))
    I = EG.roi.I(:,:,:,c_volume);
else
    I = EG.roi.I;
end

% Deal with complex data (this should ideally be done earlier and in one 
% place, but we want to keep the complex nature as long as possible)
if (any(~isreal(I(:))))
    I = abs(I); 
end

if (numel(I) > 0)
    
    if (numel(I) > 1e4)
        tmp = I(1:2:end,1:2:end,1:2:end);
    else
        tmp = I;
    end
    
    tmp = sort(tmp( (tmp(:) > 0) & (~isinf(tmp(:))) & (~isnan(tmp(:)))));
    
    if (numel(tmp) == 0)
        
        if (sum(I(:)) == 0)
            this_caxis = [0; 1];
        else
            this_caxis = [min(I(:)); max(I(:))];
        end
        
    else
        this_caxis = [0; tmp(min(round(0.995 * numel(tmp)), numel(tmp)))];
    end
else
    this_caxis = [0; 1];
end

% For parameter maps with both positive and negative values
if (any(I(:)<0))
    this_caxis = max(abs(this_caxis))*[-1; 1];
end

% For parameter maps with just small negative values
if (min(I,[],'all') > -0.05*max(I,[],'all')) || ...
        ( (-sum(I(I(:) < 0)) / sum(I(I(:) > 0))) < 0.1 )
    this_caxis = max(abs(this_caxis))*[0; 1];
end


if (this_caxis(1) > this_caxis(2))
    this_caxis = this_caxis([2 1]);
end

if (this_caxis(1) == this_caxis(2))
    this_caxis = [0.95 1.05] * this_caxis(1);
end

% Enable outside control of caxis
if (isfield(EG.data, 'ref'))
    ref = EG.data.ref(EG.browse.c_item);
    if (isfield(ref, 'caxis') && ~isempty(ref.caxis))
        this_caxis = ref.caxis;
    end
end

EG.roi.caxis = this_caxis;