function [byte_order, datatype] = mdm_mif_byte_order(h)
% function [byte_order, datatype] = mdm_mif_byte_order(h)
%
% Preliminary implementation


switch (lower(h.datatype(end-1:end)))
    
    case 'le'
        byte_order = 'l';
        datatype = h.datatype(1:end-2);
    
    case 'be'
        byte_order = 'b';
        datatype = h.datatype(1:end-2);
    
    otherwise
        
        if strcmpi(h.datatype, 'bit')
            datatype = 'bit1';
            byte_order = 'b';
        else
            datatype = h.datatype;
            byte_order = 'n';
        end
        
end