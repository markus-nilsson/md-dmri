function [h, h_str] = mdm_mif_read_header(mif_fn)
% function [h, h_str] = mdm_mif_read_header(mif_fn)

if (~exist(mif_fn, 'file'))
    error('Could not find file'); 
end

fid = fopen(mif_fn, 'r');

h.RZ = eye(4);
c_transform = 1;
h_str = [];

while (~feof(fid))
    
    tline = fgetl(fid);
    
    h_str = [h_str tline sprintf('\n')];
    
    if (strcmp(tline(1:3), 'END')), break; end
    
    fieldname = tline(1:(find(tline == ':', 1)-1));
    datastring = tline( (numel(fieldname) + 2):end);
    
    if (fieldname == '.'), continue; end
    if (numel(fieldname) == 0), continue; end
    
    switch (fieldname)
        
        case {'dim', 'vox'}
            h.(fieldname) = str2num(datastring);
            
        case 'transform'
            h.RZ(c_transform,:) = str2num(datastring);
            c_transform = c_transform + 1;
            
        case 'datatype'
            h.datatype = strtrim(datastring); 
            
        otherwise
            h.(fieldname) = datastring;
            
    end
    
end
fclose(fid);

[~,n] = strtok(h.file);
n = str2num(n);
h_tmp = zeros(1,n);
h_tmp(1:numel(h_str)) = h_str;
h_str = h_tmp;


