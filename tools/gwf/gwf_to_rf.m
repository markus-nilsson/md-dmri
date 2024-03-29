function rf = gwf_to_rf(g, rf)
% function rf = gwf_to_rf(gwf)
%
% Tries to guess the pause periods where RF pulses are played out
%
% Note: This is quite sketchy – RF behavious should be specified by the
% user. Use with caution. 

if (nargin < 2), rf = []; end
if (~isempty(rf)), return; end % deals with init situations

ind1 = 2:(size(g,1)-2); % exclude first and last points
ind2 = ind1 + 1;

f = @(x) abs(x) < eps;

ind_start = find( ...
    ( f(g(ind2,1)) &  f(g(ind2,2)) &  f(g(ind2,3))) & ...
    (~f(g(ind1,1)) | ~f(g(ind1,2)) | ~f(g(ind1,3)))) + 2;

ind_end = find( ...
    ( f(g(ind1,1)) &  f(g(ind1,2)) &  f(g(ind1,3))) & ...
    (~f(g(ind2,1)) | ~f(g(ind2,2)) | ~f(g(ind2,3)))) + 1;


if (numel(ind_start) ~= numel(ind_end))
    error('failed to find proper start and end points');
end

if (numel(ind_start) ~= 1)
    if (all(abs(sum(g,1)) < size(g,1)*eps))
        rf = ones(size(g,1), 1); return;
    else
        error('situation not yet encountered');
    end
end

% Assume an inversion pulse in the middle
rf = ones(size(g,1), 1);
ind_mid = round(ind_start + (ind_end-ind_start)/2);
rf(ind_mid:end) = -1;