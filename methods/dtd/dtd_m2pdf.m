function dtd_m2pdf(paths, opt)
% function dtd_m2pdf(dps_fn, pdf_path, opt)
 
mfs = mdm_mfs_load(paths.mfs_fn);
dps = mdm_dps_load(paths.dps_fn);
sz = size(mfs.m);
if ~isfield(paths,'pdf_path')
    paths.pdf_path = paths.nii_path;
end
msf_mkdir(paths.pdf_path);

figsize = 2*11*[1 1];
fs = 2*6;
lw = 2*1;
ms_max = 2*10;

figaspect = figsize(1)/figsize(2);
width = .998;
height = width*figaspect;
sub_width = 1/sz(1);
sub_height = 1/sz(2)*figaspect;

s0max = max(reshape(dps.s0,numel(dps.s0),1));
w_threshold = .01;
s0_threshold = .1;

figure(1), clf
set(gcf, 'PaperUnits','centimeters', 'PaperPosition', min(sz(1:2))/16*[0 0 figsize],'PaperSize', min(sz(1:2))/16*figsize);

left = .001;
bottom = .001;
axes('position',[left bottom width height])

nk = ceil(sz(3)/2);
z = squeeze(dps.s0(:,:,nk))';
clim = max(z(:))*[0 1];
hs0 = imagesc(z);
set(gca,'YDir','normal','CLim',clim)
axis off
colormap('gray')
hold on

grid.yx = repmat(0:1:sz(1),[2 1]);
grid.yy = repmat([0; sz(2)],[1 sz(1)+1]);
grid.xx = repmat([0; sz(1)],[1 sz(2)+1]);
grid.xy = repmat(0:1:sz(2),[2 1]);

plot(.5+grid.xx,.5+grid.xy,'-k','LineWidth',.5)
plot(.5+grid.yx,.5+grid.yy,'-k','LineWidth',.5)

delete(hs0)

dmin = opt.dtd.dmin;
dmax = opt.dtd.dmax;
ratiomin = dmin/dmax;
ratiomax = dmax/dmin;

xmin = log10(dmin);
xmax = log10(dmax);
ymin = log10(1/ratiomax);
ymax = log10(ratiomax);

%for nk = 1:sz(3)
    for nj = 1:sz(2)
        for ni = 1:sz(1)
            if dps.mask(ni,nj,nk)
                m = squeeze(mfs.m(ni,nj,nk,:))';
                s0 = dps.s0(ni,nj,nk);
                if s0 > s0_threshold*s0max
                    dtd = dtd_m2dtd(m);
                    [n,par,perp,theta,phi,w] = dtd_dist2par(dtd);
                    if n>0
                        xcos = cos(phi).*sin(theta);
                        ycos = sin(phi).*sin(theta);
                        zcos = cos(theta);

                        iso = tm_eigvals2iso([par perp perp]);
                        fa = tm_eigvals2fa([par perp perp]);

                        c.x = log10(iso);
                        c.y = log10(par./perp);
                        c.ms = ms_max*sqrt(w/s0max);
                        c.bright = fa;
                        c.r = abs(xcos);
                        c.g = abs(ycos);
                        c.b = abs(zcos);

                        sub_left = (ni-1)*sub_width;
                        sub_bottom = (nj-1)*sub_height;
                        axh1 = axes('position',[sub_left sub_bottom sub_width sub_height]);
                        for nc = 1:n
                            if w(nc) > w_threshold*s0
                                h1 = plot(c.x(nc),c.y(nc),'o','LineWidth',.1);
                                hold on
                                col = c.bright(nc)*[c.r(nc) c.g(nc) c.b(nc)];
                                %set(h1,'MarkerSize',c.ms(nc),'Color',col,'MarkerFaceColor',col)
                                set(h1,'MarkerSize',c.ms(nc),'Color',col,'MarkerFaceColor','none','LineWidth',.5*lw)
                            end
                        end
                        set(axh1,'XLim',[xmin xmax]+.01*(xmax-xmin)*[-1 1], 'YLim',[ymin ymax]+.01*(ymax-ymin)*[-1 1],'XTick',[],'YTick',[])
                        axis(axh1,'square','off')
                       end
                end
             end
        end
    end
%end

eval(['print ' paths.pdf_path '/Figure4_DTDarray -loose -dpng -r600'])

figure(2), clf
set(gcf, 'PaperUnits','centimeters', 'PaperPosition', 1*[0 0 .5*figsize],'PaperSize', .5*figsize);
axh2 = axes('position',[.02 .14 .84 .84]);
hold on
Nbin = numel(opt.dtd.bin_disomax);
for nbin = 1:Nbin
    disomin = opt.dtd.bin_disomin(nbin);
    disomax = opt.dtd.bin_disomax(nbin);
    dratiomin = opt.dtd.bin_dratiomin(nbin);
    dratiomax = opt.dtd.bin_dratiomax(nbin);
    
    ph = plot(log10([disomin disomax disomax disomin disomin]),...
        log10([dratiomin dratiomin dratiomax dratiomax dratiomin]),...
        'k-','LineWidth',.5*lw);
    set(ph,'Color',.7*[1 1 1])
end

%for nk = 1:sz(3)
    for nj = 1:sz(2)
        for ni = 1:sz(1)
            if dps.mask(ni,nj,nk)
                m = squeeze(mfs.m(ni,nj,nk,:))';
                s0 = dps.s0(ni,nj,nk);
                if s0 > s0_threshold*s0max
                    dtd = dtd_m2dtd(m);
                    [n,par,perp,theta,phi,w] = dtd_dist2par(dtd);
                    if n>0
                        xcos = cos(phi).*sin(theta);
                        ycos = sin(phi).*sin(theta);
                        zcos = cos(theta);

                        iso = tm_eigvals2iso([par perp perp]);
                        fa = tm_eigvals2fa([par perp perp]);

                        c.x = log10(iso);
                        c.y = log10(par./perp);
                        c.ms = ms_max*sqrt(w/s0max);
                        c.bright = fa;
                        c.r = abs(xcos);
                        c.g = abs(ycos);
                        c.b = abs(zcos);

                        for nc = 1:n
                            if w(nc) > w_threshold*s0
                                h1 = plot(c.x(nc),c.y(nc),'o','LineWidth',.01);
                                col = c.bright(nc)*[c.r(nc) c.g(nc) c.b(nc)];
                                set(h1,'MarkerSize',c.ms(nc),'Color',col,'MarkerFaceColor','none','LineWidth',.5*lw)
                            end
                        end
                    end
                end
             end
        end
    end
%end
set(axh2,'XLim',[xmin xmax]+.01*(xmax-xmin)*[-1 1], 'YLim',[ymin ymax]+.01*(ymax-ymin)*[-1 1],'YAxisLocation','right',...
'XTick',[-11:-8],'YTick',-2:2,'TickDir','out','TickLength',.02*[1 1],...
'Box','on','FontSize',fs,'LineWidth',lw)
axis square
%xlabel('log(\itD\rm_{iso} / m^2s^-^1)','FontSize',fs)
%ylabel('log(\itD\rm_{||} / \itD\rm_{\perp})','FontSize',fs)


eval(['print ' paths.pdf_path '/Figure4_DTDglobal -loose -dpng -r1200'])

% ptot = sum(sum(sum(p,1),2),3);
% z = reshape(ptot,[nx ny]);
% x = dist_s.x;
% y = dist_s.y;
% 
% zprojx = sum(z,2);
% zprojy = sum(z,1);
% 
% nclevels = 12;
% clevels = max(z(:))*linspace(0,1,nclevels+2);
% clevels = clevels(2:(nclevels+1));
% 
% left = .1;
% bottom = .72;
% height = .2;
% width = height/figaspect;
% proj_height = height*.3;
% proj_width = proj_height/figaspect;
% 
% axes('position',[left bottom width height])
% contour(x,y,z',clevels,'LineWidth',.25*lw,'Color',[0 0 0])
% set(gca,'XLim',[xmin xmax], 'YLim',[ymin ymax],'YAxisLocation','right',...
% 'XTick',[-11:-8],'YTick',-2:2,'TickDir','out','TickLength',.03*[1 1],...
% 'FontSize',fs,'LineWidth',lw)
% axis square
% xlabel('log(\itD\rm_{iso}/m^2s^-^1)','FontSize',fs)
% ylabel('log(\itD\rm_{||}/\itD\rm_{\perp})','FontSize',fs)
% 
% axes('position',[left bottom+height width proj_height])
% plot(x,zprojx/max(zprojx),'k-','LineWidth',lw)
% set(gca,'XLim',[xmin xmax], 'YLim',[-.3 1.1])
% axis off
% 
% axes('position',[left-proj_width bottom proj_width height])
% plot(zprojy/max(zprojy),y,'k-','LineWidth',lw)
% set(gca,'YLim',[ymin ymax], 'XLim',[-.3 1.1],'XDir','reverse')
% axis off
% 
% odf_s.w = squeeze(sum(sum(sum(odf_p,1),2),3));
% odf_s.verts = repmat(odf_s.w,[1 3]).*[odf_s.x odf_s.y odf_s.z];
% 
% height = .3;
% width = height/figaspect;
% left = 1-width;
% bottom = 1-height;
% axh_ODFrec = axes('position',[left bottom width height])
% p_h = patch('Faces',odf_s.tri,'Vertices',.9*odf_s.verts/max(odf_s.w));
% axis tight, axis square, axis equal
% view(30,10)
% xlabel('x')
%     set(p_h,'FaceColor','interp','FaceVertexCData',odf_s.c,...
%     'EdgeColor','none','LineWidth',.1)
% % set(p_h,'FaceColor',[1 1 1],'FaceVertexCData',odf_s.c,...
% % 'EdgeColor','k','LineWidth',.125*lw)
% hold on
% plot3([-1 1],[0 0],[0 0],'k-','LineWidth',lw)
% plot3([0 0],[-1 1],[0 0],'k-','LineWidth',lw)
% plot3([0 0],[0 0],[-1 1],'k-','LineWidth',lw)
% axis off
% axis(1*[-1 1 -1 1 -1 1])
% xlabel('\itx\rm','FontSize',fs)
% ylabel('\ity\rm','FontSize',fs)
% zlabel('\itz\rm','FontSize',fs)

% 
% nclevels = 5;
% clevels = max(p(:))*linspace(0,1,nclevels+2);
% clevels = clevels(2:(nclevels+1));
% 
% param = 'ufa';
% col = 's1x6prim';
% colnorm = 'slambda33prim';
% 
% 
% for nk = 1:sz(3)
%     eval(['c.bright = dps.' param '(:,:,nk);'])
%     eval(['c.r = squeeze(abs(dps.' col '(:,:,nk,1)))./dps.' colnorm ';'])
%     eval(['c.g = squeeze(abs(dps.' col '(:,:,nk,2)))./dps.' colnorm ';'])
%     eval(['c.b = squeeze(abs(dps.' col '(:,:,nk,3)))./dps.' colnorm ';'])
% 
%     Icol = zeros(size(c.bright,2),size(c.bright,1),3);
%     Icol(:,:,1) = (c.bright.*c.r);
%     Icol(:,:,2) = (c.bright.*c.g);
%     Icol(:,:,3) = (c.bright.*c.b);
%     Icol(isnan(Icol)) = 0;
%     Icol(isinf(Icol)) = 0;
%     Icol(Icol>1) = 1;
%     Icol(Icol<0) = 0;
% 
%     for nj = 1:sz(2)
%         for ni = 1:sz(1)
%             if dps.mask(ni,nj,nk)                
%                 z = reshape(p(ni,nj,nk,:),[nx ny]);                
%                 if sum(z)~=0                
%                     sub_left = (ni-1)*sub_width;
%                     sub_bottom = (nj-1)*sub_height;
%                     axes('position',[sub_left sub_bottom sub_width sub_height])
%                     contour(x,y,z',clevels,'LineWidth',1*lw,'Color',[Icol(ni,nj,1) Icol(ni,nj,2) Icol(ni,nj,3)])
%                     set(gca,'XLim',[xmin xmax], 'YLim',[ymin ymax],'XTick',[],'YTick',[])
%                     axis square
%                     axis off
%                 end
%                 pause(.1)
%             end            
%         end
%     end
% end





