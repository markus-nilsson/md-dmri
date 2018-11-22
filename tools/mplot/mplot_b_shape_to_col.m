function col = mplot_b_shape_to_col(b_delta, b_eta)
% function col = mplot_b_delta_to_col(b_delta, b_eta)
%
% Return the plot color for a certain b-delta


% b_delta = 1 --> green
%           0 --> gray
%        -0.5 --> red

lte_col = [0.4 0.75 0.2];
ste_col = [0.4 0.4 0.4];
pte_col = [0.8 0.4 0.3];
   

cmap = cat(1, ...
    linspace(1,0,100)' * lte_col + ...
    linspace(0,1,100)' * ste_col, ...
    ...
    linspace(1,0,49)' * ste_col + ...
    linspace(0,1,49)' * pte_col);
    
cmap = flipud(cmap);

ind = 1 + floor( ((b_delta + 0.5) / 1.51) * size(cmap,1));



col = cmap( ind, :);
