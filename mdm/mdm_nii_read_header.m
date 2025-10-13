function h = mdm_nii_read_header(nii_fn, do_print)
% function h = mdm_nii_read_header(nii_fn)

if (nargin < 2), do_print = 0; end

% Possibly unzip the file
[nii_fn, tmp_path, tmp_nii_fn] = mdm_nii_gunzip(nii_fn, 1);
if (~exist(nii_fn, 'file')), error(['File does not exist: ' nii_fn]); end

% read the nifti header
fid = fopen(nii_fn, 'r');
h.sizeof_hdr        = fread(fid, 1, 'int32'); 
h.data_type         = fread(fid, 10, 'uint8');	
h.db_name           = fread(fid, 18, 'uint8');
h.extents           = fread(fid, 1, 'int32');
h.session_error     = fread(fid, 1, 'int16');		
h.regular           = fread(fid, 1, 'uint8');	 			
h.dim_info           = fread(fid, 1, 'uint8');	 				
h.dim               = fread(fid, 8, 'int16');           % Data array dimensions.[size, x, y, z, time, Na, Na, Na]
h.intent_p1         = fread(fid, 1, 'float32');	 		% 1st intent parameter. 							                                                     /* short unused9;       */
h.intent_p2         = fread(fid, 1, 'float32');			% 2nd intent parameter. 
h.intent_p3         = fread(fid, 1, 'float32');			% 3rd intent parameter. 
h.intent_code       = fread(fid, 1, 'int16');           % NIFTI_INTENT
h.datatype          = fread(fid, 1, 'int16');           % Defines data type![integer 4, float 8]
h.bitpix            = fread(fid, 1, 'int16');           % Number bits/voxel.    
h.slice_start       = fread(fid, 1, 'int16');           % First slice index.   
h.pixdim            = fread(fid, 8, 'float32');         % Grid spacings.        
h.vox_offset        = fread(fid, 1, 'float32');         % Offset into .nii file 
h.scl_slope         = fread(fid, 1, 'float32');         % Data scaling: slope.[y = scl_slope * x + scl_inter]
h.scl_inter         = fread(fid, 1, 'float32');         % Data scaling: offset. 
h.slice_end         = fread(fid, 1, 'int16');           % Last slice index.     
h.slice_code        = fread(fid, 1, 'uint8');           % Slice timing order.   
h.xyzt_units 		= fread(fid, 1, 'uint8');           % Units of pixdim[1..4] 
h.cal_max           = fread(fid, 1, 'float32');         % Max display intensity 
h.cal_min           = fread(fid, 1, 'float32');         % Min display intensity
h.slice_duration 	= fread(fid, 1, 'float32');         % Time for 1 slice.     
h.toffset           = fread(fid, 1, 'float32');         % Time axis shift.      
h.glmax 			= fread(fid, 1, 'int32'); 
h.glmin             = fread(fid, 1, 'int32');  	
h.descrip           = fread(fid, 80, 'uint8');          % any text you like.    
h.aux_file          = fread(fid, 24, 'uint8');          % auxiliary nii_fn.   
h.qform_code 		= fread(fid, 1, 'int16');           % NIFTI_XFORM_* code.  
h.sform_code        = fread(fid, 1, 'int16');           % NIFTI_XFORM_* code.   
h.quatern_b         = fread(fid, 1, 'float32');         % Quaternion b param.   
h.quatern_c         = fread(fid, 1, 'float32');         % Quaternion c param.   
h.quatern_d  		= fread(fid, 1, 'float32');         % Quaternion d param.   
h.qoffset_x 		= fread(fid, 1, 'float32');         % Quaternion x shift.  
h.qoffset_y  		= fread(fid, 1, 'float32');         % Quaternion y shift.   
h.qoffset_z  		= fread(fid, 1, 'float32');         % Quaternion z shift.   
h.srow_x            = fread(fid, 4, 'float32');         % 1st row affine transform.   
h.srow_y 			= fread(fid, 4, 'float32');         % 2nd row affine transform.   
h.srow_z 			= fread(fid, 4, 'float32');         % 3rd row affine transform.   
h.intent_name		= fread(fid, 16, 'uint8');          % name or meaning of data.  
h.magic             = fread(fid, 8, 'uint8');            % should be 'n+ 1'

% Close down and remove the temp file
fclose(fid);
if (~isempty(tmp_nii_fn)), delete(tmp_nii_fn); end
if (~isempty(tmp_path)), rmdir(tmp_path); end


if (do_print)
    disp(sprintf('h.descrip:\t %s', char(h.descrip')));    
    disp(sprintf('h.db_name:\t %s', char(h.db_name')));  
    disp(sprintf('h.pixdim: \t %1.2fx%1.2fx%1.2f', h.pixdim(2), h.pixdim(3), h.pixdim(4)));  
    disp(sprintf('h.dim:    \t %ix%ix%ix%i', h.dim(2), h.dim(3), h.dim(4), h.dim(5)));  
end

