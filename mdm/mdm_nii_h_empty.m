function h = mdm_nii_h_empty()
% function h = mdm_nii_h_empty()
% create a header where all apppropriate fields for the nifti header exists

h.sizeof_hdr      = zeros(1, 1, 'int32'); 
h.data_type       = zeros(1, 10, 'uint8');	
h.db_name         = zeros(1, 18, 'uint8');
h.extents         = zeros(1, 1, 'int32');
h.session_error   = zeros(1, 1, 'int16');		
h.regular         = zeros(1, 1, 'uint8');	 			
h.dim_info        = zeros(1, 1, 'uint8');	 				
h.dim             = zeros(1, 8, 'int16');             % Data array dimensions.[size, x, y, z, time, Na, Na, Na]
h.intent_p1       = zeros(1, 1, 'single');	 		% 1st intent parameter. 							                                                     /* short unused9;       */
h.intent_p2       = zeros(1, 1, 'single');			% 2nd intent parameter. 
h.intent_p3       = zeros(1, 1, 'single');			% 3rd intent parameter. 
h.intent_code     = zeros(1, 1, 'int16');              % NIFTI_INTENT
h.datatype        = zeros(1, 1, 'int16');              % Defines data type![integer 4, float 8]
h.bitpix          = zeros(1, 1, 'int16');              % Number bits/voxel.    
h.slice_start     = zeros(1, 1, 'int16');              % First slice index.   
h.pixdim          = single([1 1 1 1 0 0 0 0]);          % Grid spacings.        
h.vox_offset      = zeros(1, 1, 'single');            % Offset into .nii file 
h.scl_slope       = zeros(1, 1, 'single') + 1;        % Data scaling: slope.[y = scl_slope * x + scl_inter]
h.scl_inter       = zeros(1, 1, 'single');            % Data scaling: offset. 
h.slice_end		  = zeros(1, 1, 'int16');              % Last slice index.     
h.slice_code 	  = zeros(1, 1, 'uint8');              %Slice timing order.   
h.xyzt_units 	  = zeros(1, 1, 'uint8');              % Units of pixdim[1..4] 
h.cal_max 		  = zeros(1, 1, 'single');            % Max display intensity 
h.cal_min 		  = zeros(1, 1, 'single');            % Min display intensity
h.slice_duration  = zeros(1, 1, 'single');            % Time for 1 slice.     
h.toffset 		  = zeros(1, 1, 'single');            % Time axis shift.      
h.glmax 		  = zeros(1, 1, 'int32'); 
h.glmin			  = zeros(1, 1, 'int32');  	
h.descrip         = zeros(1, 80, 'uint8');                % any text you like.    
h.aux_file        = zeros(1, 24, 'uint8');                % auxiliary filename.   
h.qform_code 	  = zeros(1, 1, 'int16');                 % NIFTI_XFORM_* code.  
h.sform_code  	  = int16(1); %zeros(1, 1, 'int16');                 % NIFTI_XFORM_* code.   
h.quatern_b   	  = zeros(1, 1, 'single');               % Quaternion b param.   
h.quatern_c   	  = zeros(1, 1, 'single');               % Quaternion c param.   
h.quatern_d  	  = zeros(1, 1, 'single');               % Quaternion d param.   
h.qoffset_x 	  = zeros(1, 1, 'single');               % Quaternion x shift.  
h.qoffset_y  	  = zeros(1, 1, 'single');               % Quaternion y shift.   
h.qoffset_z  	  = zeros(1, 1, 'single');               % Quaternion z shift.   
h.srow_x  		  = single([-1 0 0 0])';              % 1st row affine transform.   
h.srow_y 		  = single([0 1 0 0])';               % 2nd row affine transform.   
h.srow_z 		  = single([0 0 1 0])';                %3rd row affine transform.   
h.intent_name	  = zeros(1, 16, 'uint8');                %name or meaning of data.  
h.magic			  = char('n+1     ');                  % should be 'n+ 1'



