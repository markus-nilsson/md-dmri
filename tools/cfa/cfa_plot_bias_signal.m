function cfa_plot_bias_signal(gwf, rf, dt, ips, find_mode, do_k0)
% function cfa_plot_bias_signal(gwf, rf, dt, ips, find_mode)

if nargin < 4
    ips = cfa_ips_example();
end

if nargin < 5
    find_mode = 0;
end

if nargin < 6
    do_k0 = 1;
end

cfa_check_ips(ips);

% Rotations of the FOV and the gwf are imortant and we can fing the worst
% rotation by an fminsearch.
switch find_mode
    case 0 % let it be
        
    case 1 % Find worst rotation of gwf
        R = cfa_find_worst_gwf_rot(gwf, rf, dt, ips, 1);
        gwf = gwf * R;
        
    case 2 % Find worst rotation of FOV
        R = cfa_find_worst_fov_rot(gwf, rf, dt, ips, 1);
        ips = cfa_apply_R_to_fov(ips, R);
        
end

c = cfa_maxwell_bias(gwf, rf, dt, ips, do_k0);

[~, ind] = min(c(:));

r_worst = ips.r_xyz(ind,:);

ips2 = ips;
ips2.r_xyz = r_worst;

g2 = linspace(0, 1, 100);

c = zeros(size(g2));

for i = 1:numel(c)
    b(i) = trace(gwf_to_bt (gwf*sqrt(g2(i)), rf, dt));
    c(i) = cfa_maxwell_bias(gwf*sqrt(g2(i)), rf, dt, ips2);
end


%% PLOT
MD = 1e-9;
MK = 0.2;
s = exp(-b*MD + 1/6*b.^2*MD^2*MK);
se = s.*c;

bp = b*1e-9;

semilogy(bp, c, 'r-')
hold on 
semilogy(bp, s, 'k-', bp, se, 'k--')

ylabel('Rel. Signal and Attenuation Factor (AF)')
xlabel('b [ms/µm^2]')

legend('AF', 'Signal', 'S\cdotAF', 'location', 'best')







