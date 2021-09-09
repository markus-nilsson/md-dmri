function dtd_mkpdf(dps_fn, pdf_path, opt)
% function dtd_mkpdf(dps_fn, pdf_path, opt)
 
dps = mdm_dps_load(dps_fn);
sz = size(dps.m);


figsize = 3.3*[1.618 1];
figaspect = figsize(1)/figsize(2);
sub_width = 1/figaspect/sz(1);
sub_height = 1/sz(2);

fs = 7;
lw = 1;

figure(1), clf

height = .17;
width = height/figaspect;

nk = 1;

left = .65;
bottom = .25;
axes('position',[left bottom width height])
z = squeeze(dps.miso(:,:,nk))'/2e-9;
clim = [0 1];
imagesc(z)
set(gca,'YDir','normal','CLim',clim,'XTick',[],'YTick',[])
colormap('gray')
title('M(D_{iso})','FontSize',fs)
axis off

axes('position',[left+1*width bottom width height])
z = squeeze(dps.mdelta(:,:,nk))';
clim = [-.5 1];
imagesc(z)
set(gca,'YDir','normal','CLim',clim,'XTick',[],'YTick',[])
colormap('gray')
title('M(D_{aniso})','FontSize',fs)
axis off

axes('position',[left 0 width height])
z = squeeze(dps.ciso(:,:,nk))';
clim = [0 1];
imagesc(z)
set(gca,'YDir','normal','CLim',clim,'XTick',[],'YTick',[])
colormap('gray')
title('V(D_{iso})','FontSize',fs)
axis off

axes('position',[left+width 0 width height])
z = squeeze(dps.vdelta(:,:,nk))';
clim = [0 1];
imagesc(z)
set(gca,'YDir','normal','CLim',clim,'XTick',[],'YTick',[])
colormap('gray')
title('V(D_{aniso})','FontSize',fs)
axis off

axes('position',[left+2*width 0 width height])
param = 'ufa';
col = 's1x6prim';
colnorm = 'slambda33prim';

eval(['c.bright = dps.' param '(:,:,nk);'])
eval(['c.r = squeeze(abs(dps.' col '(:,:,nk,1)))./dps.' colnorm ';'])
eval(['c.g = squeeze(abs(dps.' col '(:,:,nk,2)))./dps.' colnorm ';'])
eval(['c.b = squeeze(abs(dps.' col '(:,:,nk,3)))./dps.' colnorm ';'])

Icol = zeros(size(c.bright,2),size(c.bright,1),3);
Icol(:,:,1) = (c.bright.*c.r)';
Icol(:,:,2) = (c.bright.*c.g)';
Icol(:,:,3) = (c.bright.*c.b)';
Icol(isnan(Icol)) = 0;
Icol(isinf(Icol)) = 0;
Icol(Icol>1) = 1;
Icol(Icol<0) = 0;

image(Icol)
set(gca,'YDir','normal')
title('uFA S_{ii}','FontSize',fs)
axis off

axes('position',[left+2*width bottom width height])
param = 'fa';
col = 't1x6';
colnorm = 'lambda33';

eval(['c.bright = dps.' param '(:,:,nk);'])
eval(['c.r = squeeze(abs(dps.' col '(:,:,nk,1)))./dps.' colnorm ';'])
eval(['c.g = squeeze(abs(dps.' col '(:,:,nk,2)))./dps.' colnorm ';'])
eval(['c.b = squeeze(abs(dps.' col '(:,:,nk,3)))./dps.' colnorm ';'])

Icol = zeros(size(c.bright,2),size(c.bright,1),3);
Icol(:,:,1) = (c.bright.*c.r)';
Icol(:,:,2) = (c.bright.*c.g)';
Icol(:,:,3) = (c.bright.*c.b)';
Icol(isnan(Icol)) = 0;
Icol(isinf(Icol)) = 0;
Icol(Icol>1) = 1;
Icol(Icol<0) = 0;

image(Icol)
set(gca,'YDir','normal')
title('FA D_{ii}','FontSize',fs)
axis off

height = 1;
width = height/figaspect;

left = 0;
bottom = 0;
axes('position',[left bottom width height])

z = squeeze(dps.s0(:,:,nk))';
clim = max(z(:))*[0 1];
imagesc(z)
set(gca,'YDir','normal','CLim',clim)
axis off
colormap('gray')
hold on


dmin = opt.dtd.dmin;
dmax = opt.dtd.dmax;
ratiomax = dmax/dmin;

nx = 30; ny = nx;
sigma_x = .2;
sigma_y = sigma_x;
xmin = log10(dmin)-3*sigma_x;
xmax = log10(dmax)+3*sigma_x;
ymin = log10(1/ratiomax)-1*sigma_y;
ymax = log10(ratiomax)+1*sigma_y;

x = linspace(xmin,xmax,nx)';
dx = x(2)-x(1);
y = linspace(ymin,ymax,ny)';
dy = y(2)-y(1);
[xx,yy] = ndgrid(x,y);

np = nx*ny;
p = zeros(sz(1), sz(2), sz(3), np);
for nk = 1:sz(3)
    for nj = 1:sz(2)
        for ni = 1:sz(1)
            if dps.mask(ni,nj,nk)
                m = squeeze(dps.m(ni,nj,nk,:))';
                dtd = dtd_m2dtd(m);
                [n,par,perp,theta,phi,w] = dtd_dist2par(dtd);
                if n>0
                    logiso = log10((par + 2*perp)/3);
                    logratio = log10(par./perp);

                    x0 = logiso(:);
                    y0 = logratio(:);
                    nx0 = n;
                    xx_k = repmat(xx(:),[1 nx0]);
                    yy_k = repmat(yy(:),[1 nx0]);
                    x0_k = repmat(x0',[nx*ny 1]);
                    y0_k = repmat(y0',[nx*ny 1]);
                    k = 1/(sigma_x*sqrt(2*pi)).*exp(-(xx_k-x0_k).^2/(2*sigma_x^2)).*...
                        1/(sigma_y*sqrt(2*pi)).*exp(-(yy_k-y0_k).^2/(2*sigma_y^2));

                    p(ni,nj,nk,:) = k*w;   
                end
             end
        end
    end
end

ptot = sum(sum(sum(p,1),2),3);
z = reshape(ptot,[nx ny]);

zprojx = sum(z,2);
zprojy = sum(z,1);

nclevels = 5;
clevels = max(z(:))*linspace(0,1,nclevels+2);
clevels = clevels(2:(nclevels+1));

left = .7;
bottom = .6;
height = .3;
width = height/figaspect;
proj_height = height*.3;
proj_width = proj_height/figaspect;

axes('position',[left bottom width height])
contour(x,y,z',clevels,'k','LineWidth',.5*lw)
set(gca,'XLim',[xmin xmax], 'YLim',[ymin ymax],'YAxisLocation','right',...
'XTick',[-11:-8],'YTick',-2:2,'TickDir','out','TickLength',.03*[1 1],...
'FontSize',fs,'LineWidth',lw)
axis square
xlabel('log(D_{iso} / m^2s^-^1)','FontSize',fs)
ylabel('log(D_{||} / D_{\perp})','FontSize',fs)

axes('position',[left bottom+height width proj_height])
plot(x,zprojx/max(zprojx),'k-')
set(gca,'XLim',[xmin xmax], 'YLim',[-.3 1.1])
axis off

axes('position',[left-proj_width bottom proj_width height])
plot(zprojy/max(zprojy),y,'k-')
set(gca,'YLim',[ymin ymax], 'XLim',[-.3 1.1],'XDir','reverse')
axis off

pause(1)

%nclevels = 3;
clevels = max(p(:))*linspace(0,1,nclevels+2);
clevels = clevels(2:(nclevels+1));

for nk = 1:sz(3)
    for nj = 1:sz(2)
        for ni = 1:sz(1)
            if dps.mask(ni,nj,nk)                
                z = reshape(p(ni,nj,nk,:),[nx ny]);                
                if sum(z)~=0                
                    sub_left = (ni-1)*sub_width;
                    sub_bottom = (nj-1)*sub_height;
                    axes('position',[sub_left sub_bottom sub_width sub_height])
                    contour(x,y,z',clevels,'k')
                    set(gca,'XLim',[xmin xmax], 'YLim',[ymin ymax],'XTick',[],'YTick',[])
                    axis square
                    axis off
                end
            end            
        end
    end
end


set(gcf, 'PaperPosition', 1*[0 0 figsize],'PaperSize', figsize);
eval(['print ' pdf_path '/dtd -loose -dpdf'])



