function s_new = mdm_s_sort(s, ind, path, opt, suffix)
% function s_new = mdm_s_sort(s, ind, path, opt, suffix)

if (nargin < 3), path = fileparts(s.nii_fn); end
if (nargin < 4), opt.present = 1; end
if (nargin < 5), suffix = 'sorted'; end
opt = mdm_opt(opt);

msf_log(['Starting ' mfilename], opt);

if (islogical(ind) && (sum(ind) == 0))
    error('index vector cannot be empty');
end

s_new = s;

% build new filename
[~,name] = msf_fileparts(s.nii_fn);
s_new.nii_fn = fullfile(path, [name '_' suffix opt.nii_ext]);

% subsample xps
s_new.xps = mdm_xps_subsample(s.xps, ind);

% subsample nii only if needed
if (exist(s_new.nii_fn, 'file') && ~opt.do_overwrite)
    disp(['Skipping, output file already exists: ' s_new.nii_fn]); 
    return;
end

mdm_nii_subsample(s.nii_fn, ind, s_new.nii_fn);

xps = s_new.xps;

mdm_xps_save(xps, mdm_xps_fn_from_nii_fn(s_new.nii_fn));


