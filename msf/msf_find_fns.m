function fn = msf_find_fns(bp, pattern, do_throw_error)
% function fn = msf_find_fn(bp, pattern)

if (nargin < 2), error('at least two input arguments required'); end
if (nargin < 3), do_throw_error = 1; end

% Allow returning empty filename if not found
if (do_throw_error == -1)
    f = @(x) 1; % be silent
    fn = [];
elseif (do_throw_error)
    f = @(x) error(x);
else
    f = @(x) disp(['msf_find_fns: ' x]);
    fn = []; % standard return
end

if (iscell(pattern))
        
    % Match to each pattern
    fn = {};
    for c = 1:numel(pattern)
        fn = cat(2, fn, msf_find_fns(bp, pattern{c}, -1));
    end
    
    if (numel(fn) == 0)
        f('msf_find_fn: Found no hits');
        fn = [];
    end
    
    return;
    
end

d = dir(fullfile(bp, pattern));

if (numel(d) == 0)
    f(sprintf('no match for pattern: %s', pattern)); return;
end

fn = cell(1,numel(d));

for c = 1:numel(d)
    fn{c} = fullfile(bp, d(c).name);
end