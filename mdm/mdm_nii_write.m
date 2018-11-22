function nii_fn = mdm_nii_write(I, nii_fn, h, is_colour)
% function mdm_nii_write(I, nii_fn, h, is_colour)

if (nargin < 4), is_colour = 0; end
if (nargin < 3) || (numel(h) == 0), h = mdm_nii_h_empty; end

% Make header consistent using an internal function
h = nii_make_header(h);

% Create temporary path if writing compressed nifti
[tmp_nii_fn, folder_gz, tmp_path] = do_gzip(nii_fn);

try
    fid = fopen(tmp_nii_fn, 'w');
    
    if (fid == -1), error(['Could not open file for writing: ' tmp_nii_fn]); end
    
    fwrite(fid, int32(h.sizeof_hdr(1)),    'int32');
    fwrite(fid, uint8(h.data_type(1:10)),  'uint8');
    fwrite(fid, uint8(h.db_name(1:18)),    'uint8');
    fwrite(fid, int32(h.extents(1)),       'int32');
    fwrite(fid, int16(h.session_error(1)), 'int16');
    fwrite(fid, uint8(h.regular(1)),       'uint8');
    fwrite(fid, uint8(h.dim_info(1)),      'uint8');
    fwrite(fid, int16(h.dim(1:8)),         'int16'); % Data array dimensions.[size, x, y, z, time, Na, Na, Na]
    fwrite(fid, single(h.intent_p1(1)),    'float32'); % 1st intent parameter. 							                                                     /* short unused9;       */
    fwrite(fid, single(h.intent_p2(1)),    'float32');
    fwrite(fid, single(h.intent_p3(1)),    'float32');
    fwrite(fid, int16(h.intent_code(1)),   'int16');
    fwrite(fid, int16(h.datatype(1)),      'int16');% Defines data type![integer 4, float 8]
    fwrite(fid, int16(h.bitpix(1)),        'int16');% Number bits/voxel.
    fwrite(fid, int16(h.slice_start(1)),   'int16');% First slice index
    fwrite(fid, single(h.pixdim(1:8)),     'float32');% Grid spacings.
    fwrite(fid, single(h.vox_offset(1)),   'float32'); % Offset into .nii file
    fwrite(fid, single(h.scl_slope(1)),    'float32');% Data scaling: slope.[y = scl_slope * x + scl_inter]
    fwrite(fid, single(h.scl_inter(1)),    'float32');% Data scaling: offset.
    fwrite(fid, int16(h.slice_end(1)),     'int16');% Last slice index.
    fwrite(fid, uint8(h.slice_code(1)),    'uint8');% Slice timing order.
    fwrite(fid, uint8(h.xyzt_units(1)),    'uint8');% Units of pixdim[1..4]
    fwrite(fid, single(h.cal_max(1)),      'float32');% Max display intensity
    fwrite(fid, single(h.cal_min(1)),      'float32');% Min display intensity
    fwrite(fid, single(h.slice_duration(1)),'float32');% Time for 1 slice.
    fwrite(fid, single(h.toffset(1)),      'float32');% Time axis shift.
    fwrite(fid, int32(h.glmax(1)),         'int32');
    fwrite(fid, int32(h.glmin(1)),         'int32');
    fwrite(fid, uint8(h.descrip(1:80)),    'uint8');% any text you like.
    fwrite(fid, uint8(h.aux_file(1:24)),   'uint8');% auxiliary filename.
    fwrite(fid, int16(h.qform_code(1)),    'int16');% NIFTI_XFORM_* code.
    fwrite(fid, int16(h.sform_code(1)),    'int16');% NIFTI_XFORM_* code.
    fwrite(fid, single(h.quatern_b(1)),    'float32');% Quaternion b,c,d param.
    fwrite(fid, single(h.quatern_c(1)),    'float32');
    fwrite(fid, single(h.quatern_d(1)),    'float32');
    fwrite(fid, single(h.qoffset_x(1)),    'float32');% Quaternion x,y,z shift.
    fwrite(fid, single(h.qoffset_y(1)),    'float32');
    fwrite(fid, single(h.qoffset_z(1)),    'float32');
    fwrite(fid, single(h.srow_x(1:4)),     'float32');% 1st, 2nd, 3rd row affine transform.
    fwrite(fid, single(h.srow_y(1:4)),     'float32');% 1st, 2nd, 3rd row affine transform.
    fwrite(fid, single(h.srow_z(1:4)),     'float32');% 1st, 2nd, 3rd row affine transform.
    fwrite(fid, uint8(h.intent_name(1:16)),'uint8');%name or meaning of data.
    fwrite(fid, uint8(h.magic(1:8)),       'uint8');% should be 'n+1'
    
    % Sanity-check
    effective_sizeof_hdr = ftell(fid) - 4; % minus the size of the h size :)
    if (effective_sizeof_hdr ~= h.sizeof_hdr)
        error(['nifti h is wrong size, aborting write (current size = ' num2str(effective_sizeof_hdr) ')']);
    end
    
    % Image is RBG-uint8 if bitpix equals 24
    if (h.bitpix == 24)
        fwrite(fid, uint8(I), 'uint8');
    else
        switch (h.datatype)
            case 1792
                I = double(I);
                J = zeros(size(I,1), size(I,2), size(I,3), size(I,4), 2);
                J(:,:,:,:,1) = real(I);
                J(:,:,:,:,2) = imag(I);
                J = permute(J, [5 1 2 3 4]);     
                fwrite(fid, J, 'float64');
            case 512
                fwrite(fid, uint16(I), 'uint16');
            case 256
                fwrite(fid, int8(I), 'int8');
            case 64
                fwrite(fid, double(I), 'float64');
            case 32
                I = single(I);
                J = zeros(size(I,1), size(I,2), size(I,3), size(I,4), 2);
                J(:,:,:,:,1) = real(I);
                J(:,:,:,:,2) = imag(I);
                J = permute(J, [5 1 2 3 4]);
                
                fwrite(fid, J, 'float32');
            case 16
                fwrite(fid, single(I), 'float32');
            case 4
                fwrite(fid, int16(I), 'int16');
            case 2
                fwrite(fid, uint8(I), 'uint8');
            otherwise
                error('value in h.datatype is not supported');
        end
    end
    fclose(fid);
    
catch me
    
    % Clear up and rethrow error
    fclose(fid);
    delete(tmp_nii_fn);
    rmdir(tmp_path,'s');
    rethrow(me);
end

% gzip the temporary file
if (~isempty(folder_gz))
    msf_mkdir(folder_gz);
    gzip(tmp_nii_fn, folder_gz);
    delete(tmp_nii_fn);
    rmdir(tmp_path,'s');
end


    function h = nii_make_header(h)
        
        % This ought to be a standard nifti-file of whichever format...
        h.sizeof_hdr = 348;
        h.vox_offset = 352; % sizeof_hdr takes 4 bytes
        
        % Dimensions
        h.dim = ones(8,1,'int16');
        h.dim(1) = ndims(I);
        h.dim(2) = size(I,1);
        h.dim(3) = size(I,2);
        h.dim(4) = size(I,3);
        h.dim(5) = size(I,4);
        
        % Determine the datatype
        tmp = whos('I');
        
        is_complex = ~(isreal(I(:)));
        
        class_str = tmp.class;
        
        if (is_complex), class_str = ['complex_' class_str]; end
        
        
        switch (class_str)
            case 'uint8'
                h.datatype = 2;
                h.bitpix = 8;
            case 'int8'
                h.datatype = 256;
                h.bitpix = 8;
            case 'int16'
                h.datatype = 4;
                h.bitpix = 16;
            case 'uint16'
                h.datatype = 512;
                h.bitpix = 16;
            case 'single'
                h.datatype = 16;
                h.bitpix = 32;
            case 'double'
                h.datatype = 64;
                h.bitpix = 64;
            case 'complex_single'
                h.datatype = 32;
                h.bitpix = 64;
            case 'complex_double';
                h.datatype = 1792;
                h.bitpix = 128;
            otherwise
                error(['datatype ' tmp.class ' is not supported by this function']);
        end
        
        % If the image a colour image?
        if (is_colour)
            if (size(I,1) ~= 3)
                error('wrong shape of I, expecting size(I,1) == 3 when colour image');
            end
            
            if (size(I,5) ~= 1)
                error('4d volumes not allowed in colour');
            end
            
            h.bitpix = 3*8;
            h.datatype = 128;
            
            h.dim(1) = ndims(I) - 1; % == 4
            h.dim(2) = size(I,2); % dim x
            h.dim(3) = size(I,3); % dim y
            h.dim(4) = size(I,4); % n_slices
            h.dim(5) = 1;
        end
        
        % Do the magic
        h.magic = 'n+1     ';
        h.magic(4:end) = 0;
    end

    function [nii_fn, folder_gz, tmp_path] = do_gzip(nii_fn)
        % Get the extention of the file
        ext = nii_fn(max(1,end-3):end);
        switch ext
            case 'i.gz'
                tmp_path = msf_tmp_path(1);
                
                % Write the file to the system tempdir
                % (faster if using an external HD)
                [folder_gz, fn, ext] = fileparts(nii_fn(1:end-3));
                nii_fn = fullfile(tmp_path, [fn ext]);
                
                if (isempty(folder_gz)), folder_gz = pwd; end
                
            case '.nii'
                folder_gz = [];
                tmp_path = [];
                
            otherwise
                error(['Unknown file extension: ' ext]);
        end
    end

end


