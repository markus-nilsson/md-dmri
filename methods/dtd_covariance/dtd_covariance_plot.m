function dtd_covariance_plot(S, xps, h, h2)
% function dtd_covariance_plot(S, xps, h, h2)

if (nargin < 4), h2 = []; end

opt = dtd_covariance_opt();
[m,~,n] = dtd_covariance_1d_data2fit(S, xps, opt);
S_fit = dtd_covariance_1d_fit2data(m, xps);


% diffusion tensor
dt_1x6 = m(2:7)' * 1e9;
dps = tm_dt_to_dps(dt_1x6);

% covariance tensor
ct_1x21  = m(8:28)' * 1e18;
dps = tm_ct_to_dps(ct_1x21, dps);

plot(h, S, 'k.');
hold(h, 'on');
plot(h, S_fit, 'r-');
xlim(h, [0 1+numel(S_fit)]);
ylim(h, [0 max(max(S_fit), max(S)) * 1.1]);
title(h, sprintf('MD = %1.2f, FA = %1.2f\nMK_I = %1.2f, MK_A = %1.2f\n  MEAS RANK = %i', ...
    dps.MD, dps.FA, dps.MKi, dps.MKa, n));


if (1)
    
    C = m(8:end) * 1e18;
    
    [x,y,z] = sphere(120);
    
    c = zeros(size(x));
    for i = 1:size(x,1)
        for j = 1:size(x,2)
            r = [x(i,j) y(i,j) z(i,j)];
            
            r4 = tm_1x6_to_1x21(tm_1x3_to_1x6(1,0,r));
            r4 = r4 / sqrt(tm_inner(r4, r4));
            L1 = tm_inner(C, r4);
            
            L = L1;
            
            x(i,j) = x(i,j) * L;
            y(i,j) = y(i,j) * L;
            z(i,j) = z(i,j) * L;
            
            c(i,j) = L;
            
        end
    end
    
    surface(h2,x,z,y,c);
    
    caxis(h2, [0 1.5] );
    colormap(h2, fliplr(jet(100)));
    axis(h2, 'off')
    axis(h2, 'tight');
    axis(h2, 'equal');
    axis(h2, 'vis3d');
    camlight(h2, 0, 0);

    material([0.7 0.4 0.8 1]); 
    shading(h2, 'interp');

end