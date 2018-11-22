function mplot_tensors_in_voxel(dt, n_tensor, sc, n_points, col, alpha, r_std)
% function mplot_tensors_in_voxel(dt, n_tensor, sc, n_points)
%
% WIP
%
% n_tensor - number of tensors to display per voxel side
% sc       - scaling factor (adjust to rescale tensors)
% n_points - numbers of points for tensor visualization

if (nargin < 2), n_tensor = 4; end
if (nargin < 3), sc = 0.1; end
if (nargin < 4), n_points = 29; end
if (nargin < 5), col = repmat([1 0 0], n_tensor^3, 1); end
if (nargin < 6), alpha = ones(1, n_tensor^3, 1); end
if (nargin < 6), r_std = 0; end

box_lw = 1;

do_plot_box = 1;
do_show_tensors = 1;

% plot box
if (do_plot_box)
    
    lcol = [0 0 0] + 0.3;
    a = 0.65;
    b = n_tensor + 1 - a;
    
    plot3([a b b a a], [a a b b a], [a a a a a ], 'k', 'color', lcol, 'linewidth', box_lw); hold on;
    plot3([a b b a a], [a a b b a], [b b b b b ], 'k', 'color', lcol, 'linewidth', box_lw);
    plot3([a a], [a a], [a b], 'k', 'color', lcol, 'linewidth', box_lw);
    plot3([a a], [b b], [a b], 'k', 'color', lcol, 'linewidth', box_lw);
    plot3([b b], [b b], [a b], 'k', 'color', lcol, 'linewidth', box_lw);
    plot3([b b], [a a], [a b], 'k', 'color', lcol, 'linewidth', box_lw);
    
end

if (do_show_tensors)
    [x,y,z] = sphere(n_points);
    s.x = x; s.y = y; s.z = z;
    c = 1;
    for i = 1:n_tensor
        for j = 1:n_tensor
            for k = 1:n_tensor
                
                % select a tensor on random
%                 ind = randi(size(dt,1));
                
%                 col = [0.4 0.4 0.4]; % work on color scheme later
                
                mplot_tensor(dt(c,:), [i j k], sc, s, r_std, col(c,:), alpha(c));
                
                c = c+1;
                
                if (i * j * k == 1)
                    hold on;
                end
            end
        end
    end
end

caxis([-1 3]);
colormap(fliplr(hot(100)));
axis off tight equal vis3d;
camlight left;
shading interp;
material([0.7 0.4 0.8 1]);
campos([0.9 1.3 0.4] * n_tensor * 5)

