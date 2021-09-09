function [a_ind, c_list, id_ind] = mdm_pa_ind_from_xps(xps, opt)
% function [a_ind, c_list, id_ind] = mdm_pa_ind_from_xps(xps, opt)
%
% Volumes with identical rotations is defined from xps.a_ind
%
% If this does not exist, we try to compute it, but beware of errors in
% this step

if (nargin < 2), opt = []; end 
opt = mdm_opt(opt);

if (isfield(xps, 'a_ind'))
    % If the user has supplied an averaging index vector, just use it
    a_ind = xps.a_ind; 
else
    
    % assume an acquisition with varyng b and b_delta, other cases (e.g fexi)
    % are difficult to exclude here, so we'll have to figure out that later
    %
    % here we also ignore b_eta
    %
    % finally, we acknowledge that this function is a can of worms...
    if (isfield(xps, 'b') && (isfield(xps, 'b_delta')))
        
        % define step in b and b_delta
        db        = opt.mdm.pa.db * 1e-9; % units of um2/ms
        db_delta2 = opt.mdm.pa.db_delta2;
        
        b = xps.b * 1e-9;
        b_delta2 = xps.b_delta.^2 .* sign(xps.b_delta);
        
        x = [b / db b_delta2 / db_delta2];
        [~,~,a_ind] = uniquetol(x, 1/max(abs(x(:))), 'byrows', 1);

    elseif (isfield(xps, 'b'))
        
        % just do pa of b
        x = xps.b / opt.mdm.pa.db;
        [~,~,a_ind] = uniquetol(x, 1/max(abs(x)));
        
    else
        error('insufficient information to compute power average indices');
    end
end



% Find out what to average
id = a_ind;

if (isfield(xps,'s_ind'))
    id = [id xps.s_ind];
end

[~,~,id_ind] = unique(id, 'rows');

tmp = sum(isnan(id),2) > 0;

c_list = unique(id_ind(~tmp)); 

