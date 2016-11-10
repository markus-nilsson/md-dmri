function txt = mdm_txt_write(txt, txt_fn, opt)
% function txt = mdm_txt_write(txt, txt_fn, opt)
%
% This function write each line in txt, a cell, as separate lines in txt_fn

if (nargin < 3), opt.present = 1; end

opt = mdm_opt(opt);

if (iscell(txt))
    
    fid = fopen(txt_fn, 'w');
    for c = 1:numel(txt)
        fprintf(fid, '%s\n', txt{c});
    end
    fclose(fid);
    
elseif (ismatrix(txt) && isnumeric(txt))
    
    fid = fopen(txt_fn, 'w');
    for c = 1:size(txt,1)
        fprintf(fid, '%s\n', num2str(txt(c,:)));
    end
    fclose(fid);
    
    
else
    error('not a suitable format')
end