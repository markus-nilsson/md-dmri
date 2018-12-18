function [I, header, filename, ext, xps, xps_fn] = mgui_contrast_load(EG)
% function [I, header, filename, ext, xps] = mgui_contrast_load(EG)
%
% Return the image volume and filename based on the select struct

do_flip = 1;

filename = EG.browse.filename;

[~,~,ext] = msf_fileparts(filename);

% Search for .gz files if the orignal file is not present
if (~exist(filename, 'file') && exist([filename '.gz'], 'file'))
    filename = [filename '.gz'];
end

if (~exist(filename, 'file'))
    error('File does not exist: %s', filename);
end

% Nifti files are in LPS (some, at least, check this!)
% Matlab images are displayed as YX
switch (lower(ext))
    case '.dcm'
        I = dicomread(filename);
        header = mdm_nii_h_empty;
        header.my_hdr.ori = 'LAS';
    otherwise % assume nifti
        [I, header] = mdm_nii_read(filename);
        header.my_hdr.ori = mdm_nii_oricode(header);
end
I = double(I);


[~,name] = fileparts(filename);
header.my_hdr.protocol_name = name(max(find(name == '_', 2))+1:end);

if (header.bitpix == 24)
    I = permute(I, [2 3 4 1]);
end

if (header.bitpix == 8) && (header.dim(2) == 3)
    I = permute(I, [1 2 3 4]);
    I = reshape(I(:), 128, 128, 60, 3);
    header.bitpix = 24;
end

if (header.scl_slope ~= 0)
    I = I * double(header.scl_slope);
end

if (header.scl_inter ~= 0)
    I = I + double(header.scl_inter);
end

% Possibly scale according to my_header.ref_scale
if (isfield(header.my_hdr, 'ref_scale') && ...
        header.my_hdr.ref_scale ~= 0)
    I = I / header.my_hdr.ref_scale;
end



% Get xps: Check if there is some file that could provide info for the xps
for c_attempt = 1:4
    switch (c_attempt)
        case 1
            xps_fn = mdm_xps_fn_from_nii_fn(filename);
            fn = @(x) mdm_xps_load(x);
        case 2
            xps_fn = mdm_fn_nii2gdir(filename);
            fn = @(x) mdm_xps_from_gdir(x);
        case 3
            [xps_fn, bvec_fn] = mdm_fn_nii2bvalbvec(filename);  
            fn = @(x) mdm_xps_from_bval_bvec(x, bvec_fn);
        case 4            
            xps_fn = mdm_xps_fn_from_nii_fn(filename);
            xps.n = size(I,4);
    end
    
    if (exist(xps_fn, 'file'))
        xps = fn(xps_fn); 
        break; 
    end
end

    
% Rotate the volume
if (do_flip) && (isfield(header, 'my_hdr') && (isfield(header.my_hdr,'ori')))
    [I,p] = mgui_misc_flip_volume(I, header.my_hdr.ori, EG.conf.ori);
    
    if (isfield(header, 'pixdim'))
        header.pixdim(2:4) = header.pixdim(p + 1);
    end
end

