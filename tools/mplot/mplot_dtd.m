function h = mplot_dtd(t_1x6, w, dmin, dmax, h, opt)
% function h = mplot_dtd(t_1x6, w, dmin, dmax, h)
%
% Plot the distribution of diffusion tensors in a 2D plot
%
% t_1x6    - list of discrete tensors
% w        - relative weight of each tensor in the distribution
% dmin     - min isotropic diffusivity (for determining axis limits)
% dmax     - max isotropic diffusivity
% h        - reference to the plot area
% opt      - options
%            for powder averaged plotting, set opt.mplot.dtd_col_mode = 0

if (nargin < 2), w = []; end
if (nargin < 3), dmin = []; end
if (nargin < 4), dmax = []; end
if (nargin < 5), h = gca; end
if (nargin < 6), opt = []; end

% Autoconfigure weights: assume equal weights
if (isempty(w)), w = ones(size(t_1x6,1), 1); end

% Autoconfigure axis limits if needed
if (isempty(dmin) || isempty(dmax))
    iso = t_1x6 * [1 1 1 0 0 0] / 3;
    dmin = round(min(iso) * 1e9 * 10) / 10;
    dmax = round(max(iso) * 1e9 * 10) / 10;
end

% Autoconfigure options
opt = mplot_opt(opt);



ratiomax = dmax/dmin;

xmin = log10(dmin);
xmax = log10(dmax);
ymin = log10(1/ratiomax);
ymax = log10(ratiomax);

% convert weights to marker sizes
w = w / sum(w);
ms = 5 * opt.mplot.ms * sqrt(w);
ms = real(ms);

if (max(ms) > 15), ms = ms / 15 * 15; end

cla(h,'reset'); hold(h, 'on');

switch (opt.mplot.dtd_plot_type)
    
    case 'point_estimate'
        
        for c = 1:size(t_1x6) % loop over the tensors in the distribution
            if (ms(c) == 0), continue; end
            
            p = tm_3x3_to_tpars(tm_1x6_to_3x3(t_1x6(c,:)));
            
            x = log10(p.iso);
            y = log10(p.para/p.perp);
            
            if (opt.mplot.dtd_col_mode > 0)
                col = p.fa * abs(p.norm);
            else
                col = 'black';
            end
            
            plot(h,x,y,'o',...
                'LineWidth',.01, ...
                'MarkerSize',ms(c),...
                'Color',col,...
                'MarkerFaceColor','none');
        end
        
    case 'population_contour'
        
        nx = 100; ny = nx;
        
        sigma_x = .15;
        sigma_y = sigma_x;
        
        x = linspace(xmin,xmax,nx)';
        y = linspace(ymin,ymax,ny)';
        
        [xx,yy] = ndgrid(x,y);
        
        logiso = zeros(1, size(t_1x6,1)); logratio = logiso;
        for c = 1:size(t_1x6,1)

            p = tm_3x3_to_tpars(tm_1x6_to_3x3(t_1x6(c,:)));
            
            logiso(c) = log10((p.para + 2*p.perp)/3);
            logratio(c) = log10(p.para./p.perp);
        end
            
        x0 = logiso(:);
        y0 = logratio(:);
        nx0 = size(t_1x6,1);
        xx_k = repmat(xx(:),[1 nx0]);
        yy_k = repmat(yy(:),[1 nx0]);
        x0_k = repmat(x0',[nx*ny 1]);
        y0_k = repmat(y0',[nx*ny 1]);
        
        k = 1/(sigma_x*sqrt(2*pi)).*exp(-(xx_k-x0_k).^2/(2*sigma_x^2)).*...
            1/(sigma_y*sqrt(2*pi)).*exp(-(yy_k-y0_k).^2/(2*sigma_y^2));
        
        ptot = k*w;
        
        z = reshape(ptot,[nx ny]);
        
%         zprojx = sum(z,2); 
%         zprojy = sum(z,1);
        
        nclevels = 5;
        clevels = max(z(:))*linspace(0,1,nclevels+2);
        clevels = clevels(2:(nclevels+1));

        contour(h,x,y,z',clevels,'k','LineWidth',.5*opt.mplot.lw)

end

set(h,...
    'XLim',[xmin xmax], ...
    'YLim',[ymin ymax], ...
    'YAxisLocation','right', ...
    'XTick', -12:.5:-8, ...
    'YTick',-3:.5:3, ...
    'TickDir','out', ...
    'TickLength',.02*[1 1], ...
    'FontSize',opt.mplot.fs, ...
    'LineWidth',opt.mplot.lw, ...
    'Box','on')

axis(h,'square');

xlabel(h,'"size", log_{10}(\it{D}\rm_{iso} / m^2s^-^1)','FontSize',opt.mplot.fs)
ylabel(h,'"shape", log_{10}(\it{D}\rm_{A} / \it{D}\rm_{R})','FontSize',opt.mplot.fs)

% if (opt.mplot.dtd_col_mode > 0)
%     title(h,'orientation, [RGB]=[xyz]_ ','FontSize',opt.mplot.fs,'FontWeight','normal')
% end

