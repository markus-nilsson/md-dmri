function fn = mdm_param2nii(dps_fn, o_path, fig_opt, opt)
% function fn = mdm_param2nii(dps_fn, o_path, fig_opt, opt)
%
% Save parameters from dps as nifti files
%
% Input:
% dps_fn  - filename to display parameter structure
% o_path  - output path
% fig_opt - figure options, with two important fields
%           fig_opt.fig_maps: cell array with contrasts to save to nii
%           fig_opt.fig_cmaps: cell array with color maps to save to nii
%
% Optional:
% opt     - options structure
%
% Output:
% fn      - cell array with written nifti files


if (nargin < 4), opt = []; end

opt = mdm_opt(opt);

if (opt.do_param2nii == 0)
    disp('Returning (opt.do_param2nii == 0)');
    return;
end

% init: do not require any figures to be made
fig_opt = msf_ensure_field(fig_opt, 'fig_maps', {});
fig_opt = msf_ensure_field(fig_opt, 'fig_cmaps', {});

dps = [];
fn  = {};

% grayscale maps
for n = 1:numel(fig_opt.fig_maps)
    
    param = fig_opt.fig_maps{n};
    
    tmp_fn = fullfile(o_path, [fig_opt.fig_prefix '_' param opt.nii_ext]);
    
    if (exist(tmp_fn, 'file') && (~opt.do_overwrite))
        continue;
    end
    
    % Just-in-time loading, to reduce times in pipe mode
    if (isempty(dps)), dps = mdm_dps_load(dps_fn); end
    
    % Replace NaNs with zeros
    tmp = dps.(param);
    tmp(isnan(tmp(:))) = 0;
    
    try
        mdm_nii_write(tmp, tmp_fn, dps.nii_h);
    catch me
        disp(me.message);
    end
    
    fn{end+1} = tmp_fn;
end

% color maps
for n = 1:numel(fig_opt.fig_cmaps)
    
    param   = fig_opt.fig_cmaps{n};
    col     = fig_opt.fig_ccol{n};
    colnorm = fig_opt.fig_ccolnorm{n};
    
    tmp_fn = fullfile(o_path, [fig_opt.fig_prefix '_' param '_' col '_rgb' opt.nii_ext]);
    
    if (exist(tmp_fn, 'file') && (~opt.do_overwrite))
        continue;
    end
    
    % Just-in-time loading, to reduce times in pipe mode
    if (isempty(dps)), dps = mdm_dps_load(dps_fn); end
    
    c.bright = dps.(param);
    c.r = squeeze(abs(dps.(col)(:,:,:,1))) ./ dps.(colnorm);
    c.g = squeeze(abs(dps.(col)(:,:,:,2))) ./ dps.(colnorm);
    c.b = squeeze(abs(dps.(col)(:,:,:,3))) ./ dps.(colnorm);
    
    I = zeros([3 msf_size(c.r,3)]);
    I(1,:,:,:) = c.bright .* c.r;
    I(2,:,:,:) = c.bright .* c.g;
    I(3,:,:,:) = c.bright .* c.b;
    
    I(isnan(I)) = 0;
    I(isinf(I)) = 0;
    
    I( I(:) > 1 ) = 1;
    I( I(:) < 0 ) = 0;
    
    try
        mdm_nii_write(255*I, tmp_fn, dps.nii_h, 1);
    catch me
        disp(me.message);
    end
    
    fn{end+1} = tmp_fn;
end

