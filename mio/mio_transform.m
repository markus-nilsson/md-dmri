function [I_out, h_out] = mio_transform(I_in, t, h, opt)
% function I_out = mio_transform(I_in, t, h, opt)
% 
% I: Image volume (x,y,z,c) to be transformed (looping over 4th dim)
% t: Elastix Transform structure
% h: Nifti header
%
% Note that the contents of h and t must be matched

if (nargin < 3), h = mdm_nii_h_empty; end
if (nargin < 4), opt.present = 1; end

opt = mio_opt(opt);

if (~isfield(opt.mio, 'tmp_path'))
    opt.mio.tmp_path = msf_tmp_path(1);
    do_rm_tmp_path = 1;
else
    do_rm_tmp_path = 0;
end

% Build output filenames
nii_fn = fullfile(opt.mio.tmp_path, 'tmp.nii');
t_fn   = fullfile(opt.mio.tmp_path, 't.txt');

elastix_p_write(t, t_fn);

n = size(I_in,4);
for c = 1:n
    
    % write file
    I_tmp = I_in(:,:,:,c);
    mdm_nii_write(I_tmp, nii_fn, h);
    
    % transform
    o_fn = elastix_run_transformix(nii_fn, t_fn, opt.mio.tmp_path);
    
    % read and reset changes imposed by elastix
    [I_tmp, h_out] = mdm_nii_read(o_fn);
    I_tmp = (I_tmp - h.scl_inter) / h.scl_slope;
        
    if (c == 1)
        I_out = zeros(size(I_tmp,1), size(I_tmp,2), size(I_tmp,3), n); 
    end
        
    I_out(:,:,:,c) = I_tmp; 
end

% Cleanup
if (do_rm_tmp_path)
    rmdir(opt.mio.tmp_path, 's');
end




