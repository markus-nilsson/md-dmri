function mdm_mif_write(I, mif_fn, h, byteorder, precision)
% function mdm_mif_write(I, mif_fn, h, byteorder, precision)
%
% Preliminary implementation

if (isstruct(h))
    error('not implemented');
    % h_str = mrtrix_mif_header_to_string(h);
else
    h_str = h;
end


% Write the header
fid = fopen (mif_fn, 'w');
fwrite(fid, uint8(h_str), 'uint8');
fclose(fid);


% Write image
precision = lower(precision);
switch (precision)
    case 'int16'
        I = int16(I);
    otherwise
        warning('check this');
        I = single(I);
end


fid = fopen (mif_fn, 'a', byteorder);
fwrite(fid, I, precision);
fclose(fid);

