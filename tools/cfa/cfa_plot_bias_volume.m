function [ha, hp] = cfa_plot_bias_volume(c, ips, slices)
% function [ha, hp] = cfa_plot_bias_volume(c, ips, slices)
%
% This funciton plots slices through a volume spanned by ips.fov.
% The color of the surface reflects the local signal error, defined by c.
% The plotted planes are defiend in the cella array "slices".

cfa_check_ips(ips);

matrix = [
    round(ips.fov(1)/ips.res(1))
    round(ips.fov(2)/ips.res(2))
    round(ips.fov(3)/ips.res(3))
    ]';

x = (1:matrix(1))*ips.res(1);
y = (1:matrix(2))*ips.res(2);
z = (1:matrix(3))*ips.res(3);

x = x - max(x)/2;
y = y - max(y)/2;
z = z - max(z)/2;

if nargin < 3 || isempty(slices)
    slices = {[x(round(length(x)/2)) max(x)],  [y(round(length(y)/2)) max(y)], z(round(length(z)/2))};
end

c = reshape(c, matrix);

hp = slice(y, x, z, c, slices{2}, slices{1}, slices{3});
ha = gca;

turn_off_lines(hp)
axis equal vis3d tight
colorbar

[min_s, ind] = min(c(:));
[f_i, p_i, s_i] = ind2sub(size(c),ind);

lb = min([min_s 1]*0.9);
caxis([lb 1])

hold on
plot3(y(p_i), x(f_i), z(s_i), 'kx', 'markersize', 10, 'LineWidth', 3)

title({['Worst error is ' num2str((min_s-1)*100, '%0.1f%%')]; ...
    ['f/p/s = ' num2str(x(f_i)) '/' num2str(y(p_i)) '/'  num2str(z(s_i))] })

xlabel('phase')
ylabel('freq')
zlabel('slice')

end


function turn_off_lines(s)
for i = 1:numel(s)
    s(i).EdgeColor = [1 1 1]*0;
    s(i).FaceAlpha = 1;
    s(i).EdgeAlpha = .05;
end
end