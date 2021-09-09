function t = tm_3x3_to_1x6(t)
% function t = tm_3x3_to_1x6(t)
%
% Convert a second-order 3x3 tensor to  Voigt-format 1x6

t = t([1 5 9 2 3 6]) .* [1 1 1 sqrt(2) sqrt(2) sqrt(2)];