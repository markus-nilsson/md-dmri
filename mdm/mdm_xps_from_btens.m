function xps = mdm_xps_from_btens(btens_fn)
% function xps = mdm_xps_from_btens(btens_fn)
%
% assume b-tensors are stored in a file where each row corresponds to a
% b-tensor in voigt format, i.e.
%
% b_xx b_yy b_zz sqrt(2) * b_xy sqrt(2) * b_xz sqrt(2) * b_yz
%
% see tm_1x3_to_1x6.m and tm_1x6_to_3x3.m for conversion between tensors
% on 3x3 or 1x6 (voigt) format.

if (~exist(btens_fn, 'file')), error('could not find %s', btens_fn); end

bten = mdm_txt_read(btens_fn);

bt = [];
for c = 1:numel(bten)
    bt = cat(1, bt, 1e9 * str2num(bten{c}));
end
    
xps = mdm_xps_from_bt(bt);