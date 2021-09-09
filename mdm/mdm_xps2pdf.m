function mdm_xps2pdf(xps_in, opt)
% function mdm_xps2pdf(xps_in, opt)
% Quick viewing of the acquisition protocol by plotting b_delta vs. b
% as points color-coded with the b-tensor orientation.

if isstruct(xps_in)
    xps = xps_in;
elseif isdir(xps_in)   
    xps = mdm_xps_load(fullfile(xps_in, 'xps.mat'));
end

figsize = 5*5*[1 1];
figaspect = figsize(1)/figsize(2);

fs = 5*10;
lw = 5*1;
ms = 5*10;

figure(1), clf
set(gcf, 'PaperUnits','centimeters', 'PaperPosition', 1*[0 0 figsize],'PaperSize', figsize);

xps = mdm_xps_calc_btpars(xps);

c.x = xps.b/1e9;
c.y = xps.b_delta;
c.ms = ms*linspace(1,.1,xps.n);
c.bright = xps.b_fa;
c.r = abs(xps.b_lambdazzvec(:,1));
c.g = abs(xps.b_lambdazzvec(:,2));
c.b = abs(xps.b_lambdazzvec(:,3));

if isfield(xps,'te')
    axh1 = axes('position',[.23 .2 .65 .8]);
    c.z = xps.te*1e3;
    for nc = 1:xps.n
        h1 = plot3(c.x(nc),c.y(nc),c.z(nc),'o','LineWidth',.01);
        hold on
        col = c.bright(nc)*[c.r(nc) c.g(nc) c.b(nc)];
        set(h1,'MarkerSize',c.ms(nc),'Color',col,'MarkerFaceColor',col)
    end

    set(axh1,'XLim',max(c.x)*[-.01 1.1], 'YLim',[-.7 1.2],'ZLim',max(c.z)*[-.01 1.01],'YAxisLocation','right',...
    'YTick',-.5:.5:1,'TickDir','out','TickLength',.03*[1 1],...
    'FontSize',fs,'LineWidth',lw)
    %axis(axh1,'square')
    xlabel('\itb\rm / 10^9 sm^-^2','FontSize',fs)
    ylabel('\itb\rm_{\Delta}','FontSize',fs)
    zlabel('TE / ms','FontSize',fs)
    view(45,30)
else
    axh1 = axes('position',[.03 .32 .65 .65]);
    for nc = 1:xps.n
        h1 = plot(c.x(nc),c.y(nc),'o','LineWidth',.01);
        hold on
        col = c.bright(nc)*[c.r(nc) c.g(nc) c.b(nc)];
        set(h1,'MarkerSize',c.ms(nc),'Color',col,'MarkerFaceColor',col)
    end

    set(axh1,'XLim',max(c.x)*[-.2 1.2], 'YLim',[-.7 1.2],'YAxisLocation','right',...
    'YTick',-.5:.5:1,'TickDir','out','TickLength',.03*[1 1],...
    'FontSize',fs,'LineWidth',lw)
    axis(axh1,'square')
    xlabel('\itb\rm / 10^9 sm^-^2','FontSize',fs)
    ylabel('\itb\rm_{\Delta}','FontSize',fs)
end

if isstruct(xps_in)
    xps = xps_in;
elseif isdir(xps_in)   
    fn = fullfile(xps_in, 'xps.pdf');
    eval(['print ' fn ' -loose -dpdf'])
end






