function [u, phi,theta] = uvec_elstat(n)
% function [u, phi,theta] = uvec_elstat(n)
%
% Loads electrostatically optimized angles for n = 10-1000

assert( (n >= 10) & (n <= 1000), 'n outside allowed range of 10-1000');

cwd = pwd;
cd(fullfile(fileparts(mfilename('fullpath')), 'repulsion_angles'));
load([num2str(n) '.mat']);
cd(cwd);

u = [sin(theta) .* cos(phi)  sin(theta) .* sin(phi) cos(theta)  ];


% i = 1; x = tm_euler_angles2rotmat(phi(i), theta(i), 0) * [0 0 1]';
% now u(i,:) = x'
