function a = msf_nanstd(a,d)
% function a = msf_nanstd(a,d)

if (nargin < 2)
    if (size(a,1) == 1), d = 2; 
    elseif (size(a,2) == 1), d = 1;
    else, error('need two arguments');
    end
end
    
a = nanstd(a, [], d);