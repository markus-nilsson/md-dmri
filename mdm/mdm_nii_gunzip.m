function [nii_fn, tmp_path, tmp_fn] = mdm_nii_gunzip(nii_fn, h_only)
% function [nii_fn, tmp_path, tmp_fn] = mdm_nii_gunzip(nii_fn, h_only)
%
% Extract the file to the system tempdir (faster if using an external HD)

if (nargin < 2), h_only = 0; end

% Get the extention of the file
ext = nii_fn(max(1,end-3):end);

switch (lower(ext))
    
    case 'i.gz'
        [tmp_path, tmp_fn] = do_gunzip(nii_fn, h_only);
        nii_fn = tmp_fn;

    case '.nii'
        
        if (exist(nii_fn,'file')) % found a file, no need to unzip
            tmp_path = [];
            tmp_fn = [];
        else % look for zipped alternative
            [nii_fn, tmp_path, tmp_fn] = mdm_nii_gunzip([nii_fn '.gz'], h_only);
        end
        
    otherwise
        error('Unknown file extension: %s', ext);
end

    function [tmp_path, tmp_fn] = do_gunzip(in_fn, h_only)
        tmp_path = msf_tmp_path(1);
        
        assert(exist(in_fn,'file') > 0, ['file not found: ' in_fn]);
        
        if (h_only && isunix)
            [~,name] = fileparts(in_fn);
            tmp_fn = fullfile(tmp_path, name);
            
            cmd = sprintf('gzip -cd "%s" | dd ibs=1024 count=1 > "%s"', ...
                in_fn, tmp_fn);
            
            [status,result] = system(cmd);
            
        elseif (isunix)
            
            [~,name] = fileparts(in_fn);
            tmp_fn = fullfile(tmp_path, name);            
            cmd = sprintf('gzip -cd "%s" > "%s"', in_fn, tmp_fn);            
            [status,result] = system(cmd);

        else
            %if (h_only), warning('quick header extraction not implemented'); end            
            tmp_fn = gunzip(in_fn, tmp_path);
            tmp_fn = tmp_fn{1};
        end
    end
end
