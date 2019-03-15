function fn = mdm_philips_dti_vectors_write(fn, u, b, name)
% function fn = mdm_philips_dti_vectors_write(fn, u, b)
%
% Writes a dti_vector_input.txt file that can be read at Philips scanners
%
% Input
% fn   - filename
% u    - encoding directions (size = n x 3)
% b    - b-values (size = n x 1, in SI units)
% name - name of vector set

if (nargin < 4), name = 'dti_vectors'; end

% check sizes of input
if (size(u, 1) ~= size(b, 1))
    error('Number of elements in u and b different');
end

if (size(u, 2) ~= 3)
    error('Wrong size of vectors');
end

if (size(b, 2) ~= 1)
    error('Wrong size of b');
end

% check that all vectors are unique
if (size(unique([u b], 'rows'), 1) ~= numel(b))
    error('All vectors/b-values must be unique');
end

% check that all vectors are of unit length
n = sum(u.^2, 2);

if (any( abs(n - 1) > 0.001))
    error('vectors must be of unit length');
end

% write it down
fid = fopen(fn, 'w');
fprintf(fid, '%s\n\r', name);
for c = 1:size(u,1)
    fprintf(fid, '%0.5f %0.5f %0.5f %f \n\r', u(c,1), u(c,2), u(c,3), b(c) * 1e-6);
end
fclose(fid);

