function [ha, hp] = cfa_plot_bias_surface(c, r_xyz)
% function [ha, hp] = cfa_plot_bias_surface(c, ips)
%
% This funciton plots an elipsoid surface defiend by points in r_xyz.
% The color of the surface reflects the local signal error, defined by c.

x = r_xyz(:,1);
y = r_xyz(:,2);
z = r_xyz(:,3);

%Generate the surface as convex hull
T = delaunayTriangulation(y,x,z);
H = convexHull(T);

%Plot the surface
hp = trisurf(H,y,x,z, c,'FaceColor','interp','FaceLighting','phong');
ha = gca;

shading interp
axis tight vis3d equal

set(hp,'edgecolor','none');  % You can turn off the edgecolor as well

[min_s, ind] = min(c(:));

lb = min([min_s 1]*0.9);
caxis([lb 1])
colorbar

hold on
plot3(y(ind), x(ind), z(ind), 'ko', 'markersize', 10, 'LineWidth', 3, 'MarkerFaceColor', 'w')

title({['Worst error is ' num2str((min_s-1)*100, '%0.1f%%')]; ...
    ['f/p/s = ' num2str(x(ind),2) '/' num2str(y(ind),2) '/'  num2str(z(ind),2)] })

xlabel('phase')
ylabel('freq')
zlabel('slice')



