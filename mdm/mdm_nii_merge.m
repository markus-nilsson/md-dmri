function out_nii_fn = mdm_nii_merge(nii_fn_cell, out_nii_fn, opt)
% function out_nii_fn = mdm_nii_merge(nii_fn_cell, out_nii_fn, opt)

if (nargin < 3), opt.present = 1; end

opt = mdm_opt(opt);



if (exist(out_nii_fn, 'file') && ~opt.do_overwrite)
    msf_fprintf(opt, 'File found, skipping (%s)\n', out_nii_fn); 
    return;
end

I = [];
for c = 1:numel(nii_fn_cell)
    
    [I_tmp,h] = mdm_nii_read_and_rescale(nii_fn_cell{c});
    
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