function out_nii_fn = mdm_nii_merge(nii_fn_cell, out_nii_fn, opt)
% function out_nii_fn = mdm_nii_merge(nii_fn_cell, out_nii_fn, opt)

if (nargin < 3), opt.present = 1; end

opt = mdm_opt(opt);

if (exist(out_nii_fn, 'file') && ~opt.do_overwrite)
    msf_fprintf(opt, 'File found, skipping (%s)\n', out_nii_fn); 
    return;
end

% read and merge files
I = [];
for c = 1:numel(nii_fn_cell)
    
    if (opt.mdm_nii_rescale)
        [I_tmp,h] = mdm_nii_read_and_rescale(nii_fn_cell{c});
    else
        [I_tmp,h] = mdm_nii_read(nii_fn_cell{c});
    end
    
    if (h.dim(1) == 3) && (h.dim(5) == 1) && (h.bitpix ~= 32) 
        warning(['this piece of code is experimental, ' ...
            'report its use to markus.nilsson@med.lu.se']); 
    
        h.dim(5) = h.dim(4);
        h.dim(4) = 1;
        h.dim(1) = 4;
        I_tmp = reshape(I_tmp, h.dim(2:5)');
    end
    
    if (c == 1)
        I = I_tmp;
    else
        
        if ...
                (size(I,1) ~= size(I_tmp,1)) || ...
                (size(I,2) ~= size(I_tmp,2)) || ...
                (size(I,3) ~= size(I_tmp,3))
            
            error('nii files to be merged are differently sizes');
            
        end
        
        I = cat(4, I, I_tmp);
    end
end

mdm_nii_write(I, out_nii_fn, h); 