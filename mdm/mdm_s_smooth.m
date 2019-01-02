function s = mdm_s_smooth(s, filter_sigma, o_path, opt)
% function s = mdm_s_smooth(s, filter_sigma, o_path, opt)
%
% Notes:
% Will return 's' without any action if filter_sigma <= 0

if (all(ischar(s))), s = struct('nii_fn', s); end

% init
if (nargin < 2), filter_sigma = 0.4; end
if (nargin < 3), o_path = fileparts(s.nii_fn); end
if (nargin < 4), opt.present = 1; end
opt = mdm_opt(opt);
msf_log(['Starting ' mfilename], opt);

% return s without further actions if filter_sigma = 0
% --> this is how it is done in all method pipelines, but it
%     may lead to unwanted behaviour in data-deletion scenarios
if (filter_sigma <= 0)
    msf_log(sprintf('-> No action needed, filter_sigma = %1.1f', ...
        filter_sigma), opt);
    return;
end


% construct the filename
[~,name] = msf_fileparts(s.nii_fn);
nii_fn = fullfile(o_path, [name '_s' opt.nii_ext]);

if (exist(nii_fn, 'file') && (~opt.do_overwrite))
    disp(['Skipping, output file already exists: ' nii_fn]);
    s.nii_fn = nii_fn;
    return; 
end

% read and smooth
[I,h]   = mdm_nii_read(s.nii_fn);
I       = mio_smooth_4d(single(I), filter_sigma, opt);

% write the smoothed volime, don't care if we overwrite anything
mdm_nii_write(single(I), nii_fn, h);

s.nii_fn = nii_fn;

% always overwrite the xps if we've written a new image data file
opt.do_overwrite = 1; 
mdm_xps_save(s.xps, mdm_xps_fn_from_nii_fn(s.nii_fn), opt);
