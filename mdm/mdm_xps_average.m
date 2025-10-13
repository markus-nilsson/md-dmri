function xps_pa = mdm_xps_average(xps, id_ind, c_list, opt)
% function xps_pa = mdm_xps_pa(xps, opt)
%
% Returns the powder-averaged xps

if (nargin < 2), opt = mdm_opt; end
if (nargin < 3), c_list = unique(id_ind)'; end
if (nargin < 4), opt = mdm_opt(); end

% Start by some house keeping
if (isfield(xps, 'n_bs')), xps_pa.n_bs = xps.n_bs; end
if (isfield(xps, 'n_bl')), xps_pa.n_bl = xps.n_bl; end
xps = msf_rmfield(xps, {'n','n_bs','n_bl','n_br'});

% Average fields in xps
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

% Remove directions and b-tensors, they no longer make sense
xps_pa = msf_rmfield(xps_pa, {'u', 'bt'});

xps_pa.n = numel(xps_pa.b);

% Remember the number of images (weight) that were averaged

xps_pa.pa_w = zeros(size(c_list));

for i = 1:numel(c_list)
   
    xps_pa.pa_w(i) = sum(id_ind == c_list(i));
    
end








