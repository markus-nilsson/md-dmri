function txt = mdm_xps_info(xps, method, opt, xps_fn)
% function txt = mdm_xps_info(xps, method, opt, xps_fn)
%
% Print protocol information

if (nargin < 2), method = ''; end
if (nargin < 3), opt = []; end
if (nargin < 4), xps_fn = []; end

if (isempty(method)), method = 'general'; end

opt = mdm_opt(opt);

f = @(m,v,txt) cat(1, txt, sprintf(m, v));


    function abbreviation = b_delta_to_abbreviation(b_delta)
        if (abs(b_delta) < 0.05)
            abbreviation = 'STE';
        elseif (b_delta > 0.95)
            abbreviation = 'LTE';
        elseif (b_delta < -0.45)
            abbreviation = 'PTE';
        elseif (b_delta > 0)
            abbreviation = 'xTE';
        elseif (b_delta < 0)
            abbreviation = 'xTE';
        end
        
    end

txt{1} = '';

% Print info about the xps: Quick for mgui_analysis_plot code
if (~isempty(xps_fn))
    
    [~,tmp,tmp_ext] = fileparts(xps_fn);
    tmp = [tmp tmp_ext];
    tmp = strrep(tmp, '_', '\_');
    
    if (exist(xps_fn, 'file'))
        txt = f('Obtained xps from: %s\n', tmp, txt);
    else
        txt = f('No xps found, looked for: %s\n', tmp, txt);
        return;
    end
end



txt = f('Summary of the eXperimental Parameter Structure (xps)', [], txt);



if (isfield(xps, 'n'))
    txt = f('Number of measurements: %i\n', xps.n, txt);
end

switch (method)
    case 'dtd_covariance'
        
        xps_pa = mdm_xps_pa(xps, opt);
        
        txt = f('Maximal b-value: %1.2f um^2/ms\n', max(xps.b) * 1e-9, txt);
        
        for c = 1:xps_pa.n
            txt = cat(1, txt, ...
                sprintf('b = %1.2f um^2/ms, b_delta = %1.1f (%s), #dirs = %i', ...
                xps_pa.b(c) * 1e-9, ...
                xps_pa.b_delta(c), ...
                b_delta_to_abbreviation(xps_pa.b_delta(c)), ...
                xps_pa.pa_w(c)));
        end
        
    case ''
        txt = f('No method specific information requested', [], txt);
        
        
    otherwise
        
        f = fieldnames(xps);
        for c = 1:numel(f)
            
            switch (f{c})
                case {'c_volume', 'n'}
                    continue; 
                case {'b', 'b_delta', 'b_eta'}
                    
                    % pull out a scaled value
                    switch (f{c})
                        case 'b'
                            sc = 1e-9;
                            unit = 'ms/um^2';
                        otherwise 
                            sc = 1;
                            unit = [];
                    end
                    
                    v = xps.(f{c}) * sc;

                    % compile the string
                    if ( (max(v) - min(v)) < 1e-9) % one value
                        tmp = sprintf('%1.1f %s', min(v), unit);
                    else % provide the range
                        tmp = sprintf('%1.1f-%1.1f %s', min(v), max(v), unit);
                    end
                    
                case {'bt', 'u'}
                    v = xps.(f{c});
                    tmp = sprintf('%ix%i matrix', size(v,1), size(v,2));
                    
                case 'xps_fn'
                    continue;
                otherwise 
                    tmp = [];
                    continue; 
            end           
            
            txt = cat(1, txt, ...
                sprintf('%s: %s', strrep(f{c}, '_', '\_'), tmp));
        end
                       
end


if (nargout == 0)
    disp(' ');
    disp('-------------------------------------------------------------');
    cellfun(@(x) disp(x), txt);
    disp('-------------------------------------------------------------');
    clear txt;
end

end