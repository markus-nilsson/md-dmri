function s = mdm_s_mask(s, mask_fun, path, opt)
% function s = mdm_s_mask(s, mask_fun, path, opt)
%
% Mask the data in s.nii_fn using mask_fun (e.g. mio_mask_simple)
%
% Save the mask as a nifti to s.mask_fn. This field is created if it does
% not exist already

% init
if (nargin < 2) || (isempty(mask_fun)), mask_fun = @mio_mask_threshold; end
if (nargin < 3) || (isempty(path)), path = fileparts(s.nii_fn); end
if (nargin < 4), opt.present = 1; end

opt = mdm_opt(opt);

msf_log(['Starting ' mfilename], opt);    

if (~opt.do_mask)
    s = msf_rmfield(s, 'mask_fn');
    msf_log(sprintf('-> Returning without masking, opt.do_mask = %i', opt.do_mask), opt);    
    return;
end

% construct the filename
if (~isfield(s,'mask_fn'))
    [~,name] = msf_fileparts(s.nii_fn);
    s.mask_fn = fullfile(path, [name '_' opt.mdm.mask_suffix opt.nii_ext]);
end

% Extra granularity over overwrite control needed here to enable use of
% masks from outside
do_overwrite = opt.do_overwrite && opt.mask.do_overwrite;
if (exist(s.mask_fn, 'file') && (~do_overwrite))
    msf_log(['Skipping, output file already exists: ' s.mask_fn], opt); 
    msf_log(sprintf(' (opt.do_overwrite = %i, opt.mask.do_overwrite = %i)', ...
        opt.do_overwrite, opt.mask.do_overwrite), opt);
    return;
end

% write the mask, don't care if we overwrite anything
[I,h] = mdm_nii_read(s.nii_fn);
if (any(imag(I(:)) ~= 0)), I = abs(I); end
M = mask_fun(I, opt);
msf_mkdir(fileparts(s.mask_fn));
mdm_nii_write(uint8(M), s.mask_fn, h);
