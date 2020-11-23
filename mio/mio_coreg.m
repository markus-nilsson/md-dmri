function [I_res,tp,h_res,elastix_t] = mio_coreg(I_mov, I_ref, p, opt, h_mov, h_ref)
% function [I_res,tp,h_res,elastix_t] = mio_coreg(I_mov, I_ref, p, opt, h_mov, h_ref)

if (nargin < 4), opt.present = 1; end
if (nargin < 5), h_mov = mdm_nii_h_empty; end
if (nargin < 6), h_ref = mdm_nii_h_empty; end

opt = mio_opt(opt);

if (~isfield(opt.mio, 'tmp_path'))
    opt.mio.tmp_path = msf_tmp_path(1);
    do_rm_tmp_path = 1;
else
    do_rm_tmp_path = 0;
end


% Build filenames
[~,~,~] =   mkdir(opt.mio.tmp_path);
ref_fn  = fullfile(opt.mio.tmp_path, 'f.nii');
mov_fn  = fullfile(opt.mio.tmp_path, 'm.nii');
p_fn    = fullfile(opt.mio.tmp_path, 'p.txt');


% Write outputs
mdm_nii_write(single(I_ref), ref_fn, h_ref);
mdm_nii_write(single(I_mov), mov_fn, h_mov);
elastix_p_write(p, p_fn);

% Run ElastiX, Read image volume and transform parameters
[res_fn, tp_fn] = elastix_run_elastix(mov_fn, ref_fn, p_fn, opt.mio.tmp_path);
[I_res,h_res] = mdm_nii_read(res_fn);

try
    tp = elastix_tp_read(tp_fn);
catch me
    msf_fprintf(opt, 'Unable to read elastix transform params (%s)', me.message);
    tp = zeros(3,4) + NaN;
end
elastix_t = elastix_p_read(tp_fn);

if (opt.mio.coreg.adjust_intensity)
    I_res = I_res / tp(2,3); % Intensity scaling by y-scale
end

% Adjust before storing
I_res = cast(I_res, 'like', I_mov);


% Cleanup
if (do_rm_tmp_path)
    rmdir(opt.mio.tmp_path, 's');
end




