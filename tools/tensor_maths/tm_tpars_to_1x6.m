function t_1x6 = tm_tpars_to_1x6(trace, delta, uvec)
% function t_1x6 = tm_tpars_to_1x6(trace, b_delta, uvec)
%
% convert a subset of tensor parameters to actual 1x6 tensors
%
% trace  -  tensor trace,      size = n or 1, 1
% delta  -  tensor anisotropy, size = n or 1, 1
% uvec   -  symmetry axis,     size = n or 1, 3


n = max([size(trace,1) size(delta,1) size(uvec,1)]);

assert(size(trace,2) == 1, 'trace should be (n or 1) x 1 in size');
assert(size(delta,2) == 1, 'delta should be (n or 1) x 1 in size');
assert(size(uvec,2) == 3,  'uvec should be (n or 1) x 3 in size');

if (size(trace,1) == 1), trace = repmat(trace, n, 1); end
if (size(delta,1) == 1), delta = repmat(delta, n, 1); end
if (size(uvec,1) == 1),  uvec  = repmat(uvec, n, 1); end

assert(size(trace,1) == n, 'trace should be (n or 1) x 1 in size');
assert(size(delta,1) == n, 'delta should be (n or 1) x 1 in size');
assert(size(uvec,1) == n, 'uvec should be (n or 1) x 3 in size');


t_stick  = tm_1x3_to_1x6(1, 0, uvec);
t_sphere = repmat(tm_3x3_to_1x6( eye(3,3) / 3 ), n, 1);

c2 = trace .* delta;
c1 = trace - c2;

t_1x6 = ...
    repmat(c1, 1, 6) .* t_sphere + ...
    repmat(c2, 1, 6) .* t_stick;

