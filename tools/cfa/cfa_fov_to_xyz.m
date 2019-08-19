function [x, y, z] = cfa_fov_to_xyz(fov, vs, fov_shift)
% fov is field of view
% vs is voxel size
% matrix is the matrix size

if nargin < 3
    fov_shift = [0 0 0];
end

fmatrix = fov ./ vs;

matrix = round(fmatrix);

tol = eps*10;

if any(abs(fmatrix./matrix-1) > tol)
    error('Check that FOV / resolution is a vector of integers!')
end

f = @(d) permute(linspace(-fov(d)/2, fov(d)/2 - vs(d), matrix(d))', circshift([1 2 3], d - 1));

x = repmat(f(1), 1, matrix(2), matrix(3)) + fov_shift(1);
y = repmat(f(2), matrix(1), 1, matrix(3)) + fov_shift(2);
z = repmat(f(3), matrix(1), matrix(2), 1) + fov_shift(3);

