function x = tm_inner(x,y)
% function x = tm_inner(x,y)
%
% Take the inner product of 'x' and 'y'.
% However, rewrite required

if (size(x,2) == 1), x = x'; end
if (size(y,2) == 1), y = y'; end


if (size(x,2) == size(y,2)) && (ndims(x) == 2)
    x = x * y';
elseif (numel(x) == numel(y))
    x = x(:)' * y(:);
else
    error('check your data');
end