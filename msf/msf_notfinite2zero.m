function x = msf_notfinite2zero(x)
%function x = msf_notfinite2zero(x)
%Replace Inf and NaN with zero

x(isfinite(x)~=1) = 0;