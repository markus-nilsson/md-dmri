function a = msf_nanmean(a,d)
% function a = msf_nanmean(a,d)

if (nargin < 2)
    if (size(a,1) == 1), d = 2; 
    elseif (size(a,2) == 1), d = 1;
    else, error('need two arguments');
    end
end
    

i = isnan(a);
a(i) = 0;
a = sum(a,d) ./ sum(~i,d);
a(a == Inf) = 0;