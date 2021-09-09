function dtd_mkpdf(dps_fn, pdf_path, opt)
% function dtd_mkpdf(dps_fn, pdf_path, opt)
 
dps = mdm_dps_load(dps_fn);
sz = size(dps.m);
msf_mkdir(pdf_path);

figsize = 2*8.3*[1 1.618];
figaspect = figsize(1)/figsize(2);
sub_width = 1/sz(1);
sub_height = 1/sz(2)*figaspect;

fs = 2*7;
lw = 2*1;

figure(1), clf
set(gcf, 'PaperUnits','centimeters', 'PaperPosition', 1*[0 0 figsize],'PaperSize', figsize);

nk = 1;

% height = .09;
% width = height/figaspect;
% 
% 
% left = .55;
% bottom = .85;
% axes('position',[left bottom width height])
% z = squeeze(dps.miso(:,:,nk))'/1e-9;
% clim = [0 1];
% imagesc(z)
% set(gca,'YDir','normal','CLim',clim,'XTick',[],'YTick',[])
% colormap('gray')
% title('M(\itD\rm_{iso})','FontSize',fs,'FontWeight','normal')
% axis off
% 
% axes('position',[left+1*width bottom width height])
% z = squeeze(dps.mdelta(:,:,nk))';
% z = abs(z);
% clim = [0 1];
% imagesc(z)
% set(gca,'YDir','normal','CLim',clim,'XTick',[],'YTick',[])
% colormap('gray')
% %title('M(D_{aniso})','FontSize',fs)
% title('M(\itD\rm_{||}-\itD\rm_{\perp})','FontSize',fs,'FontWeight','normal')
% axis off
% 
% axes('position',[left+2*width bottom width height])
% param = 'fa';
% col = 't1x6';
% colnorm = 'lambda33';
% 
% eval(['c.bright = dps.' param '(:,:,nk);'])
% eval(['c.r = squeeze(abs(dps.' col '(:,:,nk,1)))./dps.' colnorm ';'])
% eval(['c.g = squeeze(abs(dps.' col '(:,:,nk,2)))./dps.' colnorm ';'])
% eval(['c.b = squeeze(abs(dps.' col '(:,:,nk,3)))./dps.' colnorm ';'])
% 
% Icol = zeros(size(c.bright,2),size(c.bright,1),3);
% Icol(:,:,1) = (c.bright.*c.r)';
% Icol(:,:,2) = (c.bright.*c.g)';
% Icol(:,:,3) = (c.bright.*c.b)';
% Icol(isnan(Icol)) = 0;
% Icol(isinf(Icol)) = 0;
% Icol(Icol>1) = 1;
% Icol(Icol<0) = 0;
% 
% image(Icol)
% set(gca,'YDir','normal')
% title('FA M(\itD_{ii}\rm)','FontSize',fs,'FontWeight','normal')
% axis off
% 
% bottom = .7;
% axes('position',[left bottom width height])
% z = squeeze(dps.ciso(:,:,nk))';
% clim = .5*[0 1];
% imagesc(z)
% set(gca,'YDir','normal','CLim',clim,'XTick',[],'YTick',[])
% colormap('gray')
% title('V(\itD\rm_{iso})','FontSize',fs,'FontWeight','normal')
% axis off
% 
% axes('position',[left+width bottom width height])
% z = squeeze(dps.vdelta(:,:,nk))';
% clim = .5*[0 1];
% imagesc(z)
% set(gca,'YDir','normal','CLim',clim,'XTick',[],'YTick',[])
% colormap('gray')
% %title('V(D_{aniso})','FontSize',fs)
% title('V(\itD\rm_{||}-\itD\rm_{\perp})','FontSize',fs,'FontWeight','normal')
% axis off
% 
% axes('position',[left+2*width bottom width height])
% param = 'ufa';
% col = 's1x6prim';
% colnorm = 'slambda33prim';
% 
% eval(['c.bright = dps.' param '(:,:,nk);'])
% eval(['c.r = squeeze(abs(dps.' col '(:,:,nk,1)))./dps.' colnorm ';'])
% eval(['c.g = squeeze(abs(dps.' col '(:,:,nk,2)))./dps.' colnorm ';'])
% eval(['c.b = squeeze(abs(dps.' col '(:,:,nk,3)))./dps.' colnorm ';'])
% 
% Icol = zeros(size(c.bright,2),size(c.bright,1),3);
% Icol(:,:,1) = (c.bright.*c.r)';
% Icol(:,:,2) = (c.bright.*c.g)';
% Icol(:,:,3) = (c.bright.*c.b)';
% Icol(isnan(Icol)) = 0;
% Icol(isinf(Icol)) = 0;
% Icol(Icol>1) = 1;
% Icol(Icol<0) = 0;
% 
% image(Icol)
% set(gca,'YDir','normal')
% title('\muFA M(\itS_{ii}\rm)','FontSize',fs,'FontWeight','normal')
% axis off

width = 1;
height = width*figaspect;

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
ratiomin = dmin/dmax;
ratiomax = dmax/dmin;

nx = 50;
xsigma = 3/nx*log10(dmax/dmin);
xmin = log10(dmin)-3*xsigma;
xmax = log10(dmax)+3*xsigma;
ny = nx;
ysigma = 3/ny*log10(ratiomax/ratiomin);
ymin = log10(1/ratiomax)-3*ysigma;
ymax = log10(ratiomax)+3*ysigma;

dist_s.x = linspace(xmin,xmax,nx)';
dist_s.y = linspace(ymin,ymax,ny)';
dist_s.xsigma = xsigma;
dist_s.ysigma = ysigma;

n_nodes = 1000; %1000, 3994, or 15970
run_path = cd;
framework_path = fileparts(fileparts(fileparts(run_path)));
odf_path = fullfile(framework_path,'tools','uvec','repulsion_angles_tri');
load(fullfile(odf_path,num2str(n_nodes)))
odf_s.x = sin(theta).*cos(phi);
odf_s.y = sin(theta).*sin(phi);
odf_s.z = cos(theta);
odf_s.tri = tri;
ODindex = .1; %Watson distribution smoothing kernel
odf_s.kappa = 1/tan(ODindex*pi/2);

np = nx*ny;
p = zeros(sz(1), sz(2), sz(3), np);
odf_p = zeros(sz(1), sz(2), sz(3), n_nodes);
for nk = 1:sz(3)
    for nj = 1:sz(2)
        for ni = 1:sz(1)
            if dps.mask(ni,nj,nk)
                m = squeeze(dps.m(ni,nj,nk,:))';
                dtd = dtd_m2dtd(m);
                [n,par,perp,theta,phi,w] = dtd_dist2par(dtd);
                if n>0
                    dtds = dtd_dist2struct(dtd);
                    dist_d.n = dtds.n;
                    dist_d.x = log10((dtds.par + 2*dtds.perp)/3);
                    dist_d.y = log10(dtds.par./dtds.perp);
                    dist_d.w = dtds.w;
                    dist_s = dist_2d_discrete2smooth(dist_d,dist_s);
                    odf_d.x = sin(dtds.theta).*cos(dtds.phi);
                    odf_d.y = sin(dtds.theta).*sin(dtds.phi);
                    odf_d.z = cos(dtds.theta);
                    odf_d.w = dtds.w.*(dtds.par-dtds.perp);
                    odf_d.w = odf_d.w/sum(odf_d.w);
                    odf_s = dist_odf_discrete2smooth(odf_d,odf_s);

                    p(ni,nj,nk,:) = dist_s.w(:);   
                    odf_p(ni,nj,nk,:) = odf_s.w(:);   
                end
             end
        end
    end
end


ptot = sum(sum(sum(p,1),2),3);
z = reshape(ptot,[nx ny]);
x = dist_s.x;
y = dist_s.y;

zprojx = sum(z,2);
zprojy = sum(z,1);

nclevels = 12;
clevels = max(z(:))*linspace(0,1,nclevels+2);
clevels = clevels(2:(nclevels+1));

left = .1;
bottom = .72;
height = .2;
width = height/figaspect;
proj_height = height*.3;
proj_width = proj_height/figaspect;

axes('position',[left bottom width height])
contour(x,y,z',clevels,'LineWidth',.25*lw,'Color',[0 0 0])
set(gca,'XLim',[xmin xmax], 'YLim',[ymin ymax],'YAxisLocation','right',...
'XTick',[-11:-8],'YTick',-2:2,'TickDir','out','TickLength',.03*[1 1],...
'FontSize',fs,'LineWidth',lw)
axis square
xlabel('log(\itD\rm_{iso}/m^2s^-^1)','FontSize',fs)
ylabel('log(\itD\rm_{||}/\itD\rm_{\perp})','FontSize',fs)

axes('position',[left bottom+height width proj_height])
plot(x,zprojx/max(zprojx),'k-','LineWidth',lw)
set(gca,'XLim',[xmin xmax], 'YLim',[-.3 1.1])
axis off

axes('position',[left-proj_width bottom proj_width height])
plot(zprojy/max(zprojy),y,'k-','LineWidth',lw)
set(gca,'YLim',[ymin ymax], 'XLim',[-.3 1.1],'XDir','reverse')
axis off

odf_s.w = squeeze(sum(sum(sum(odf_p,1),2),3));
odf_s.verts = repmat(odf_s.w,[1 3]).*[odf_s.x odf_s.y odf_s.z];

height = .3;
width = height/figaspect;
left = 1-width;
bottom = 1-height;
axh_ODFrec = axes('position',[left bottom width height])
p_h = patch('Faces',odf_s.tri,'Vertices',.9*odf_s.verts/max(odf_s.w));
axis tight, axis square, axis equal
view(30,10)
xlabel('x')
    set(p_h,'FaceColor','interp','FaceVertexCData',odf_s.c,...
    'EdgeColor','none','LineWidth',.1)
% set(p_h,'FaceColor',[1 1 1],'FaceVertexCData',odf_s.c,...
% 'EdgeColor','k','LineWidth',.125*lw)
hold on
plot3([-1 1],[0 0],[0 0],'k-','LineWidth',lw)
plot3([0 0],[-1 1],[0 0],'k-','LineWidth',lw)
plot3([0 0],[0 0],[-1 1],'k-','LineWidth',lw)
axis off
axis(1*[-1 1 -1 1 -1 1])
xlabel('\itx\rm','FontSize',fs)
ylabel('\ity\rm','FontSize',fs)
zlabel('\itz\rm','FontSize',fs)

pause(1)

nclevels = 5;
clevels = max(p(:))*linspace(0,1,nclevels+2);
clevels = clevels(2:(nclevels+1));

param = 'ufa';
col = 's1x6prim';
colnorm = 'slambda33prim';


for nk = 1:sz(3)
    eval(['c.bright = dps.' param '(:,:,nk);'])
    eval(['c.r = squeeze(abs(dps.' col '(:,:,nk,1)))./dps.' colnorm ';'])
    eval(['c.g = squeeze(abs(dps.' col '(:,:,nk,2)))./dps.' colnorm ';'])
    eval(['c.b = squeeze(abs(dps.' col '(:,:,nk,3)))./dps.' colnorm ';'])

    Icol = zeros(size(c.bright,2),size(c.bright,1),3);
    Icol(:,:,1) = (c.bright.*c.r);
    Icol(:,:,2) = (c.bright.*c.g);
    Icol(:,:,3) = (c.bright.*c.b);
    Icol(isnan(Icol)) = 0;
    Icol(isinf(Icol)) = 0;
    Icol(Icol>1) = 1;
    Icol(Icol<0) = 0;

    for nj = 1:sz(2)
        for ni = 1:sz(1)
            if dps.mask(ni,nj,nk)                
                z = reshape(p(ni,nj,nk,:),[nx ny]);                
                if sum(z)~=0                
                    sub_left = (ni-1)*sub_width;
                    sub_bottom = (nj-1)*sub_height;
                    axes('position',[sub_left sub_bottom sub_width sub_height])
                    contour(x,y,z',clevels,'LineWidth',1*lw,'Color',[Icol(ni,nj,1) Icol(ni,nj,2) Icol(ni,nj,3)])
                    set(gca,'XLim',[xmin xmax], 'YLim',[ymin ymax],'XTick',[],'YTick',[])
                    axis square
                    axis off
                end
                pause(.1)
            end            
        end
    end
end


eval(['print ' pdf_path '/dtd -loose -dpdf'])



