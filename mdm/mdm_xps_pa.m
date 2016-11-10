function xps_pa = mdm_xps_pa(xps, opt)
% function xps = mdm_xps_pa(xps)

if (nargin < 2), opt = mdm_opt; end

[~,c_list, id_ind] = mdm_pa_ind_from_xps(xps);


% Average fields in xps
xps = rmfield(xps, 'n');
f = fieldnames(xps);
for i = 1:numel(f)
    for c = c_list'
        
        % allow text fields to be just copied
        if (all(ischar(xps.(f{i}))))
            xps_pa.(f{i}) = xps.(f{i});
            continue; 
        end
        
        try
            xps_pa.(f{i})(c == c_list,:) = mean(xps.(f{i})(id_ind == c, :), 1);
        catch
            if (opt.pa_rethrow_error)
                error('failed powder averaging field %s', f{i});
            else
                warning('failed powder averaging field %s', f{i});
            end
        end
    end
end

xps_pa.n = numel(xps_pa.b);
