function p = elastix_p_read(fn)
% function p = elastix_p_read(fn)
%
% Reads an elastix parameter structure from file

assert(exist(fn, 'file') > 0, 'Parameter file does not exist');

p = [];

start_marker    = '(';
end_marker      = ')';
fv_sep          = ' ';
str_marker      = '"';

fid = fopen(fn);

for c_loop = 1:1e4 % make sure to terminate the loop even if something goes wrong
    
    % Read line
    try
        if (feof(fid)), break; end
        tline = fgetl(fid);
    catch me
        disp([me.message ' Could not read parameter file.']);
        return;
    end
    
    start_ind = strfind(tline, start_marker);
    end_ind   = strfind(tline, end_marker);
    sep_ind   = strfind(tline, fv_sep);
    
    if (isempty(start_ind)),    continue; end
    if (isempty(end_ind)),      continue; end
    if (isempty(sep_ind)),      continue; end

    sep_ind = sep_ind(1);
    
    if (start_ind > sep_ind),   continue; end
    if (sep_ind > end_ind),     continue; end
    
    field   = tline(start_ind + 1:sep_ind - 1);
    val     = tline(sep_ind + 1:end_ind -1);
    val     = strtrim(val);
    
    % Possibly convert val to numerical
    pos = strfind(val, str_marker);
    
    if (isempty(pos))
        val = msf_str2double(val, fv_sep); 
    end
    
    % Store value
    p.(field) = val;
end

fclose(fid);


