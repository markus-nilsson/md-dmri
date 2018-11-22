function r_xyz = cfa_ellipsoid_xyz_from_fov(ips)
% function r_xyz = cfa_ellipsoid_xyz_from_fov(ips)
%
% Function creates xyz coordinates for ellipsoid that fits inside of ips.fov.

r_sph = uvec_elstat(512);
r_xyz = r_sph .* repmat(ips.fov/2, size(r_sph,1), 1);