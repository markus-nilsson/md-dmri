function [I, h, h_str] = mdm_mif_read(mif_fn)
% function [I, h, h_str] = mdm_mif_read(mif_fn)
%
% Preliminary implementation

if (~exist(mif_fn, 'file'))
    error('Could not find file');
end

[h, h_str] = mdm_mif_read_header(mif_fn);

[byte_order, datatype] = mdm_mif_byte_order(h);

if (~isfield(h, 'file'))
    offset = numel(h_str);
else
    [~,offset] = strtok(h.file);
    offset = str2num(offset);
end

% Read image data
fid = fopen(mif_fn, 'r', byte_order);
fseek(fid, offset, -1);
I = fread(fid, inf, lower(datatype));
fclose (fid);

% Scale
if (isfield(h, 'scaling'))
    q = str2double(strsplit(strtrim(h.scaling), ','));    
    I = I * q(2) + q(1);
end


% Reorder image data
order = (abs(str2num(char(h.layout)))+1);
order(order) = 1:numel(order);

if (prod(h.dim) ~= numel(I))
    numel(I)
    prod(h.dim)
    error('stop');
else
    I = reshape(I, h.dim(order));
end
I = ipermute(I, order);

layout = split_strings(h.layout, ',');
for c = 1:numel(layout)
    if (layout{c}(1) == '-')
        I = flipdim(I, c);
    end
end

end




function S = split_strings (V, delim)
S = {};
while size(V,2) > 0
    [R, V] = strtok(V,delim);
    S{end+1} = R;
end
end