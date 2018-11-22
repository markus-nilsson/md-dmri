function ips_o = cfa_apply_R_to_fov(ips, R)
% function ips_o = cfa_apply_R_to_fov(ips, R)

ips_o   = ips;
ips_o.o = ips.o * R;
