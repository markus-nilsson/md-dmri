function fn = vasco16_4d_fit2param(mfs_fn, o_path, opt)
% function fn = vasco16_4d_fit2param(mfs_fn, o_path, opt)
%
% 2do: Update this function to agree with structure of dti_euler

if (nargin < 3), opt = []; end
    
opt = mdm_opt(opt);
mfs = mdm_mfs_load(mfs_fn);
h   = mfs.nii_h; 

% create parameter maps and save them
n_map = 6;
fn = cell(1,n_map);
for c = 1:n_map
    
    min_max = [-inf inf];
    switch (c)
        
        case 1
            param = 's0';
            min_max = [0 inf];
            x = mfs.m(:,:,:,c);

        case 2
            param = 'vd';
            min_max = [0 10];
            x = sqrt(mfs.m(:,:,:,c)) * 1e3;
            
        case 3
            param = 'f_blood';
            min_max = [0 1];
            x = mfs.m(:,:,:,c);
            
        case 4
            param = 'd_blood';
            min_max = [0 10];
            x = mfs.m(:,:,:,c) * 1e9;

        case 5
            param = 'd_tissue';
            min_max = [0 4];
            x = mfs.m(:,:,:,c) * 1e9;

        case 6
            param = 'w';
            min_max = [0 4];
            x = mfs.m(:,:,:,c);
    end
    
    fn{c} = fullfile(o_path, ['vasco16_' param opt.nii_ext]);

    if isfield(opt,'vasco16') && isfield(opt.vasco16,'fig_maps')
        if ~ismember(param, opt.vasco16.fig_maps)
            continue;
        end
    end
    
    % make sure the min_max field is there
    opt.vasco16.(param).present = 1;
    opt.vasco16.(param) = msf_ensure_field(opt.vasco16.(param), 'min_max', min_max);
    
    % cut values above/below min/max limits
    x = mio_min_max_cut(x, opt.vasco16.(param).min_max);
    
    % write file
    mdm_nii_write(x, fn{c}, h);
end

