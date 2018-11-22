function R = cfa_euler_ang_to_rotmat(a, b, c, order)
% function R = cfa_euler_ang_to_rotmat(a, b, c, order)

if (nargin < 4), order = 1; end

Rx = [
    1         0       0;
    0      cos(a) -sin(a);
    0      sin(a)  cos(a)];

Ry = [
    cos(b)   0       sin(b);
    0       1         0;
    -sin(b)  0       cos(b)];

Rz = [
    cos(c) -sin(c)  0;
    sin(c) cos(c)   0;
    0       0       1];

switch (order)
    case 1
        R = Rz*Ry*Rx;
    case 2
        R = Rx*Ry*Rz;
end
