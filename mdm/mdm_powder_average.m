function s = mdm_powder_average(s, o_path, opt)
% function s = mdm_powder_average(s, o_path, opt)
%
% Average over rotations. Image volumes with identical rotations is defined
% from s.xps.a_ind
%
% To do: find a way of keeping track of number of averages per step

% Init
if (nargin < 2), o_path = fileparts(s.nii_fn); end
if (nargin < 3), opt.present = 1; end
opt = mdm_opt(opt);
msf_log(['Starting ' mfilename], opt);


% Build filenames: if input is a nii filename, convert to structure
if (all(ischar(s))), s = mdm_nii_to_s(s); end

% Build filenames: either o_path is a filename or a output path, treat
% the data differently depending on this
if (strcmpi(o_path(max(1, end-5):end), '.nii.gz'))
    out_nii_fn = o_path;
    out_xps_fn = mdm_xps_fn_from_nii_fn(out_nii_fn);
else
    [~,name] = msf_fileparts(s.nii_fn);
    out_nii_fn = fullfile(o_path, [name '_pa' opt.nii_ext]);
    out_xps_fn = fullfile(o_path, [name '_pa_xps.mat']);
end


% Do not overwrite
if (exist(out_nii_fn, 'file') && (~opt.do_overwrite))
    disp(['Skipping, output file already exists: ' out_nii_fn]); 
    s.xps = mdm_xps_load(out_xps_fn); 
    s.nii_fn = out_nii_fn;
    return;
end



% Run the powder averaging functions
[I,h] = mdm_nii_read(s.nii_fn);
I = mio_pa(I, s.xps);
s.xps = mdm_xps_pa(s.xps); 


% Build a new file name and save
s.nii_fn = out_nii_fn;
mdm_nii_write(single(I), s.nii_fn, h);

% For good manners, save the xps as well
mdm_xps_save(s.xps, out_xps_fn); 
