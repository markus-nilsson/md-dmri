function xps = mdm_xps_merge(xps_cell, opt)
% function xps = mdm_xps_merge(xps_cell, opt)
%
% xps_cell could be a cell of xps structres or filenames

if (nargin < 2), opt.present = 1; end
opt = mdm_opt(opt);

if (~iscell(xps_cell)), error('first argument must be a cell array'); end
if (numel(xps_cell) == 0), error('first argument empty'); end

% Load xps's
if (~isstruct(xps_cell{1}))
    if (exist(xps_cell{1}, 'file'))
        % assume all are files, load them
        for c = 1:numel(xps_cell)
            xps_cell{c} = mdm_xps_load(xps_cell{c});
        end
    else
        error('unknown input (file does not exist?)');
    end
end

% Check that all xps structs are fine
for c = 1:numel(xps_cell)
    mdm_xps_check(xps_cell{c});
end

% see if all components already have s_ind structures that are unique
tmp = cellfun(@(x) isfield(x, 's_ind'), xps_cell);

if (all(tmp)) % all have s_ind's
    s_ind = [];
    for c = 1:numel(xps_cell)
        if (any(ismember(xps_cell{c}.s_ind, s_ind)))
            error('s_ind exist, but is non-unique, address before merge');
        end
        s_ind = cat(1, s_ind, xps_cell{c}.s_ind);
    end
    
    % everything's ok!
    
elseif (~any(tmp)) % not one has an s_ind
    for c = 1:numel(xps_cell)
        xps_cell{c}.s_ind = zeros(xps_cell{c}.n, 1) + c;
    end
else % some but not all have s_ind's
    error('merging xps structures with (partly) existing s_ind is ambigious');
end




xps = xps_cell{1};

if (isfield(xps,'intent'))
    for c = 1:numel(xps)
        if (~isfield(xps_cell{c}, 'intent'))
            error('intent must be set in all xps structs, or none');
        end
        if (~strcmp(xps_cell{1}.intent, xps_cell{c}.intent))
            error('detecting mixed intents, aborting - clear intent before merge');
        end
    end
end

f = fieldnames(xps_cell{1});

for i = 2:numel(xps_cell)
    
    f2 = fieldnames(xps_cell{i});
    
    if (numel(f) ~= numel(f2))
        error('different number of fields present in the xps to be merged');
    end
    
    for c = 1:numel(f)
        
        if (~isfield(xps_cell{i}, f{c}))
            error('Discrepant fields present in the xps to be merged');
        end
        
        if (strcmp(f{c}, 'intent'))
            1;
        else
            
            try
                xps.(f{c}) = cat(1, xps.(f{c}), xps_cell{i}.(f{c}));
            catch me
                if (opt.mdm_merge_rethrow_error)
                    rethrow(me);
                else
                    fprintf('field %s could not be merged\n', f{c});
                end
            end
        end
        
        
    end
    
end


xps.n = sum(xps.n);