function mplot_tensor(dt, d, sc, s, r_std, col, alpha)
% function mplot_tensor(dt, d, sc, s, r_std)
%
% dt - diffusion tensor in voigt format
% d  - tensor center 1x3 vector
% sc - tensor scaling
% s  - coordinates
% r_std - random displacement

if (nargin < 2), d = [0 0 0]; end
if (nargin < 3), sc = 1; end
if (nargin < 4), [x,y,z] = sphere(59); s.x = x; s.y = y; s.z = z; end
if (nargin < 5), r_std = 0; end
if (nargin < 6), col = [0.5 0.5 0.5]; end
if (nargin < 7), alpha = 1; end


dt_3x3 = tm_1x6_to_3x3(dt);

[M, eig_vals] = eigs(dt_3x3);
eig_vals = diag(eig_vals) * 1e9;

eig_vals = sqrt(eig_vals);

f = @(x,y,z) sc * [x(:) y(:) z(:)] * M';
g = @(x,y,z) cellfun(@(p) reshape(p,size(x,1),size(x,2)), ...
    mat2cell(f(x,y,z),numel(x), [1 1 1]), 'uniformoutput', 0);

p = g(...
    s.x * eig_vals(1), ...
    s.y * eig_vals(2), ...
    s.z * eig_vals(3));

[x3,y3,z3] = deal(p{:});

r = randn(1,3) * r_std;

h = surface(...
    x3 + d(1) + r(1), ...
    y3 + d(2) + r(2), ...
    z3 + d(3) + r(3), ...
    'EdgeColor','none', ...
    'FaceColor', col, ...
    'FaceAlpha', alpha, ...
    'CData', zeros(size(x3)) + mean(eig_vals));

if (0)
    caxis([-1 3]);
    colormap(fliplr(jet(100)));
    axis off tight equal vis3d;
    camlight left;
    shading interp;
    material([0.7 0.4 0.8 1] );
end
