function m = dtr1r2d_plot(S, xps, axh, axh2, opt)
% function dtr1r2d_plot(S, xps, axh, axh2)

if (nargin < 4), axh2 = []; end
if (nargin < 5), opt = []; end

ms = 5;
fs = 10;
lw = 1;

opt = mdm_opt(opt);
opt = dtd_opt(opt);
opt = dtr1r2d_opt(opt);
opt = mplot_opt(opt);

opt.dtr1r2d.dmin = .05/max(xps.b);
opt.dtr1r2d.r1min = .2/max(xps.tr(xps.tr<20));
opt.dtr1r2d.r1max = 1/min(xps.tr);
opt.dtr1r2d.r2min = .2/max(xps.te);
opt.dtr1r2d.r2max = 3/min(xps.te);
opt.dtr1r2d.r2max

S = abs(S);

m = feval('dtr1r2d_1d_data2fit', S, xps, opt);
S_fit = feval('dtr1r2d_1d_fit2data', m, xps)';

% Get dps from dtr1r2d_4d_fit2param
mfs.m = zeros(1,1,1,numel(m)); mfs.m(1,1,1,:) = m;
dps = dtr1r2d_4d_fit2param(mfs.m);


dmin = opt.dtr1r2d.dmin;
dmax = opt.dtr1r2d.dmax;
ratiomin = dmin/dmax;
ratiomax = dmax/dmin;
r1min = opt.dtr1r2d.r1min;
r1max = opt.dtr1r2d.r1max;
r2min = opt.dtr1r2d.r2min;
r2max = opt.dtr1r2d.r2max;

xmin = log10(dmin);
xmax = log10(dmax);
ymin = log10(1/ratiomax);
ymax = log10(ratiomax);
zmin = log10(r1min);
zmax = log10(r1max);

[n,dpar,dperp,theta,phi,r1,r2,w] = dtr1r2d_dist2par(dtr1r2d_m2dtr1r2d(m));
diso = (dpar+2*dperp)/3;
dratio = dpar./dperp;
s0 = sum(w);

cla(axh);
hold(axh, 'off');
h1 = plot(axh,1:xps.n,S,'ro',1:xps.n,S_fit,'k.');
set(h1,'MarkerSize',ms,'LineWidth',lw)
axis(axh,'tight')
set(axh,'XLim',xps.n*[-.1 1.1], 'YLim',s0*[-.1 1.1],...
    'Box','off','TickDir','out','TickLength',.02*[1 1],...
'FontSize',fs,'LineWidth',lw)
set(axh,'YLim',max([S_fit(:); S(:)])*[-.1 1.1])
xlabel(axh,'Acq number','FontSize',fs)
ylabel(axh,'Signal','FontSize',fs)

cla(axh2);
hold(axh2, 'on');
axis(axh2,'on')

if n>0

%     dist_d.x = log10(diso);
%     dist_d.y = log10(dratio);
%     dist_d.z = log10(r1);
%     dist_d.a = 200*w/s0;
%     dist_d.r = abs(cos(phi).*sin(theta));
%     dist_d.g = abs(sin(phi).*sin(theta));
%     dist_d.b = abs(cos(theta));
%     dist_d.bright = (abs(squeeze(dpar)-squeeze(dperp))./max([squeeze(dpar) squeeze(dperp)],[],2)).^2;
%     
%     contourpars.Nx = 50; contourpars.Ny = contourpars.Nx; contourpars.Nz = contourpars.Nx; contourpars.Nlevels = 5;
%     axpars.xmin = log10(dmin)-.2; axpars.xmax = log10(dmax)+.2; axpars.ymin = log10(ratiomin)-.2; axpars.ymax = log10(ratiomax)+.2; axpars.zmin = log10(r1min)-.2; axpars.zmax = log10(r1max)+.2; 
% 
%     [hax,hscatter,hcontour] = dist_3d_scattercontourplot(axh2,dist_d,contourpars,axpars);
%     
%     set(axh2,'LineWidth',lw,'FontSize',fs)
%     set(axh2,'XTick',-11:.5:-8,'YTick',-2:1:2,'ZTick',-1:.5:2,'XGrid','on','YGrid','on','ZGrid','on','Projection','perspective')
% 
%     xlabel(axh2,{'log_{10}(\itD\rm_{iso} / m^2s^-^1)'; '"size"'},'FontSize',fs) 
%     ylabel(axh2,{'log_{10}(\itD\rm_{A} / \itD\rm_{R})'; '"shape"'},'FontSize',fs);
%     zlabel(axh2,'log_{10}(\it{R}\rm_1 / s^-^1)','FontSize',fs)
%     title(axh2,['orientation, [RGB]=[xyz]'],'FontSize',fs,'FontWeight','normal');
    
    dist_d.x = log10(diso);
    dist_d.y = log10(dratio);
    dist_d.z = log10(r2);
    dist_d.a = 500*w/s0;
    dist_d.r = abs(cos(phi).*sin(theta));
    dist_d.g = abs(sin(phi).*sin(theta));
    dist_d.b = abs(cos(theta));
    dist_d.bright = (abs(squeeze(dpar)-squeeze(dperp))./max([squeeze(dpar) squeeze(dperp)],[],2)).^2;
    
    contourpars.Nx = 50; contourpars.Ny = contourpars.Nx; contourpars.Nz = contourpars.Nx; contourpars.Nlevels = 5;
    axpars.xmin = log10(dmin)-.2; axpars.xmax = log10(dmax)+.2; axpars.ymin = log10(ratiomin)-.2; axpars.ymax = log10(ratiomax)+.2; axpars.zmin = log10(r2min)-.2; axpars.zmax = log10(r2max)+.5; 

    [hax,hscatter,hcontour] = dist_3d_scattercontourplot(axh2,dist_d,contourpars,axpars);
    
    set(axh2,'LineWidth',lw,'FontSize',fs)
    set(axh2,'XTick',-11:.5:-8,'YTick',-2:1:2,'ZTick',0:.5:2,'XGrid','on','YGrid','on','ZGrid','on','Projection','perspective')

    xlabel(axh2,{'log_{10}(\itD\rm_{iso} / m^2s^-^1)'; '"size"'},'FontSize',fs) 
    ylabel(axh2,{'log_{10}(\itD\rm_{A} / \itD\rm_{R})'; '"shape"'},'FontSize',fs);
    zlabel(axh2,'log_{10}(\it{R}\rm_2 / s^-^1)','FontSize',fs)
    title(axh2,['orientation, [RGB]=[xyz]'],'FontSize',fs,'FontWeight','normal');

end

axh2 = mplot_dtr1r2d_addtitle(dps, axh2, opt);
