function dtd_covariance_plot(S, xps, h, h2, opt)
% function dtd_covariance_plot(S, xps, h, h2)

if (nargin < 3), h  = gca; end
if (nargin < 4), h2 = []; end
if (nargin < 5), opt = []; end

opt = dtd_covariance_opt(opt);
opt = mplot_opt(opt);
opt = mdm_opt(opt);

% turn on regularization?
opt.dtd_covariance.do_regularization = 1;

% fit and produce fitted signal + display parameters
[m,~,n_rank] = dtd_covariance_1d_data2fit(S, xps, opt);
S_fit = dtd_covariance_1d_fit2data(m, xps);
dps = dtd_covariance_1d_fit2param(m, [], opt);


% plot with powder average, but also visualize the directions
xps_pa = mdm_xps_pa(msf_rmfield(xps, 'c_volume'));

opt.mio.pa.method = 'ari'; % avoid some strange misrepresentations
S_pa = squeeze(mio_pa(permute(cat(2, S, S_fit), [2 3 4 1]), xps, opt));


c_case = 1;
switch (c_case)
    
    case 1       
        
        % find unique b_deltas
        b_delta_input = round(xps_pa.b_delta * 100) / 100;
        [b_delta_uni,~] = unique(b_delta_input);
        b_delta_uni = sort(b_delta_uni);
        
        % Plot lines for the legend
        hold(h, 'off');
        for c = 1:numel(b_delta_uni)
            col = mplot_b_shape_to_col(b_delta_uni(c));
            semilogy(h, -1,2,'-', 'color', col, 'linewidth', 2); hold(h,'on');
        end
        
                       
                
        for c = 1:numel(b_delta_uni)
            
            % get all data for this b_delta
            ind = abs(xps_pa.b_delta - b_delta_uni(c)) < opt.mdm.pa.db_delta2;
            
            b = xps_pa.b(ind);
            
            col = mplot_b_shape_to_col(b_delta_uni(c));
            
            semilogy(h, b * 1e-9, S_pa(1,ind) / dps.s0, 'o', ...
                'markersize', 5, 'color', col, ...
                'markerfacecolor', col); 
            hold(h, 'on');
            
            % predict a pa signal
            if (1)
                
                b_pa = linspace(0, max(xps.b) * 1.05, 100);
                signal_pa = zeros(size(b_pa));
                for c_b = 1:numel(b_pa)
                    bt_tmp = tm_tpars_to_1x6(b_pa(c_b), b_delta_uni(c), uvec_tricosa);
                    xps_tmp = mdm_xps_from_bt(bt_tmp);
                    signal_pa(c_b) = mean(dtd_covariance_1d_fit2data(m, xps_tmp));
                end
                
                semilogy(h, b_pa * 1e-9, signal_pa / dps.s0, '-', 'linewidth', 2, 'color', col);
            end

            
            % plot the actual datapoints
            for c_b = 1:numel(b)
                
                ind2 = abs(xps.b_delta - b_delta_uni(c)) < opt.mdm.pa.db_delta2;
                ind2 = ind2 & abs(xps.b - b(c_b)) < opt.mdm.pa.db;
                
                % see how well aligned it is with the primary direction
                p = linspace(-1, 1, sum(ind2))';
                p = p / 10;
                
                [~,ind3] = sort(S_fit(ind2));
                sf = @(x) x(ind3);
                
                
                plot(h, (b(c_b) * 1e-9 + p), sf(S(ind2)) / dps.s0, 'k.', 'color', col);
                plot(h, (b(c_b) * 1e-9 + p), sf(S_fit(ind2)) / dps.s0, 'k-', 'color', col);
                
            end
            
            
        end
        
        xlim(h, [0 max(xps.b) * 1.1e-9]);
        
        if (dps.MD > 2)
            ylim(h, [0.005 1.1]);
        else
            ylim(h, [0.03 1.1]);
        end
    
        
        set(h,...
            'TickDir','out', ...
            'TickLength',.02*[1 1], ...
            'FontSize',opt.mplot.fs, ...
            'LineWidth',opt.mplot.lw, ...
            'Box','off');
        
        xlabel(h, 'b [ms/um^2]', 'fontsize', opt.mplot.fs);
        ylabel(h, 'Signal', 'fontsize', opt.mplot.fs);
        
        
        l_str = cell(1,numel(b_delta_uni));
        for c = 1:numel(b_delta_uni)
            col = mplot_b_shape_to_col(b_delta_uni(c));
            plot(h,10,10,'-', 'color', col, 'linewidth', 2);
            hold(h, 'on');
            l_str{c} = ['b_\Delta = ' num2str(b_delta_uni(c))];
        end
        legend(h, l_str, 'location', 'southwest');
        legend(h, 'boxoff');
        

        
    
    case 2 % old plot
        
        plot(h, S, 'k.');
        hold(h, 'on');
        plot(h, S_fit, 'r-');
        xlim(h, [0 1+numel(S_fit)]);
        ylim(h, [0 max(max(S_fit), max(S)) * 1.1]);
end


title(h, sprintf([...
    'MD = %1.2f, FA = %1.2f, uFA = %1.2f\n' ...
    'MK_I = %1.2f, MK_A = %1.2f\n' ...
    'MEAS RANK = %i, REG FIT = %i'], ...
    dps.MD, dps.FA, dps.uFA, ...
    dps.MKi, dps.MKa, ...
    n_rank, opt.dtd_covariance.do_regularization));


if ~isempty(h2)
    
    C = m(8:end) * 1e18;
    
    C = C + tm_1x6_to_1x21(m(2:7) * 1e9);
    
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