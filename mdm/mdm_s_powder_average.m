function s = mdm_s_powder_average(s, o_path, opt)
% function s = mdm_s_powder_average(s, o_path, opt)
%
% Average over rotations. Image volumes with identical rotations is defined
% from s.xps.a_ind
%
% To do: find a way of keeping track of number of averages per step

% Init
if ( (nargin < 2) || isempty(o_path) ), o_path = fileparts(s.nii_fn); end
if (nargin < 3), opt.present = 1; end
opt = mdm_opt(opt);
msf_log(['Starting ' mfilename], opt);


% Build filenames: either o_path is a filename or a output path, treat
% the data differently depending on this
if (strcmpi(o_path(max(1, end-6):end), '.nii.gz'))
    out_nii_fn = o_path;
    out_xps_fn = mdm_xps_fn_from_nii_fn(out_nii_fn);
else
    [~,name] = msf_fileparts(s.nii_fn);
    out_nii_fn = fullfile(o_path, [name '_' opt.mdm.pa_suffix opt.nii_ext]);
    out_xps_fn = mdm_xps_fn_from_nii_fn(out_nii_fn);
end

% Is already powder averaged?
if (isfield(s.xps, 'pa_w'))
    disp('Skipping, input file is already powder averaged');
    return;
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
[I,S] = mio_pa(I, s.xps, opt);
s.xps = mdm_xps_pa(s.xps, opt); 


% Build a new file name and save
s.nii_fn = out_nii_fn;
mdm_nii_write(single(I), s.nii_fn, h);

% For good manners, save the xps as well
mdm_xps_save(s.xps, out_xps_fn); 


% If requested, save the std as well
if (opt.mdm.pa_std)
    nii_std_fn = fullfile(o_path, [name '_' opt.mdm.pa_suffix '_std' opt.nii_ext]);
    mdm_nii_write(single(S), nii_std_fn, h);   
end
