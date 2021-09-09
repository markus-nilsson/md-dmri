function dtr2d_m2pdf(dps_fn, pdf_path, opt)
% function dtr2d_m2pdf(dps_fn, pdf_path, opt)
 
dps = mdm_dps_load(dps_fn);
sz = size(dps.m);
msf_mkdir(pdf_path);

figsize = 5*10*[1 1];
fs = 5*10;
lw = 5*1;
ms_max = 5*2;

figaspect = figsize(1)/figsize(2);
width = 1;
height = width*figaspect;
sub_width = 1/sz(1);
sub_height = 1/sz(2)*figaspect;

s0max = max(reshape(dps.s0,numel(dps.s0),1));
w_threshold = 0;
s0_threshold = 0;

clim = .9*s0max*[0 1];

dmin = opt.dtr2d.dmin;
dmax = opt.dtr2d.dmax;
ratiomin = dmin/dmax;
ratiomax = dmax/dmin;
r2min = opt.dtr2d.r2min;
r2max = opt.dtr2d.r2max;

xmin = log10(dmin);
xmax = log10(dmax);
ymin = log10(1/ratiomax);
ymax = log10(ratiomax);
zmin = log10(r2min);
zmax = log10(r2max);

if isfield(opt,'nk_range')
    nk_range = opt.nk_range;
else
    nk_range =  1:sz(3);
end
if isfield(opt,'nj_range')
    nj_range = opt.nj_range;
else
    nj_range =  1:sz(2);
end
if isfield(opt,'ni_range')
    ni_range = opt.ni_range;
else
    ni_range =  1:sz(1);
end

for nk = nk_range
    figure(1), clf
    set(gcf, 'PaperUnits','centimeters', 'PaperPosition', [0 0 figsize],'PaperSize', figsize);
    left = 0;
    bottom = 0;
    axes('position',[left bottom width height])
    z = squeeze(dps.s0(:,:,nk))';
    imagesc(z)
    set(gca,'YDir','normal','CLim',clim)
    axis off
    colormap('gray')
    hold on
    for nj = nj_range
        for ni = ni_range
            if dps.mask(ni,nj,nk)
                m = squeeze(dps.m(ni,nj,nk,:))';
                s0 = dps.s0(ni,nj,nk);
                if s0 > s0_threshold*s0max
                    dtr2d = dtr2d_m2dtr2d(m);
                    [n,par,perp,theta,phi,r2,w] = dtr2d_dist2par(dtr2d);
                    if n>0
                        xcos = cos(phi).*sin(theta);
                        ycos = sin(phi).*sin(theta);
                        zcos = cos(theta);

                        iso = tm_eigvals2iso([par perp perp]);
                        fa = tm_eigvals2fa([par perp perp]);

                        c.x = log10(iso);
                        c.y = log10(par./perp);
                        c.ms = 100/min(sz(1:2))*ms_max*sqrt(w/s0max);
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
                                set(h1,'MarkerSize',c.ms(nc),'Color',col,'MarkerFaceColor',col)
                            end
                        end
                        set(axh1,'XLim',[xmin xmax]+.2*(xmax-xmin)*[-1 1], 'YLim',[ymin ymax]+.2*(ymax-ymin)*[-1 1],'XTick',[],'YTick',[])
                        axis(axh1,'square','off')
                        %pause(.05)
                       end
                end
             end
        end
    end
% eval(['print ' pdf_path '/dtr2d_2Dmap -loose -dpdf'])
eval(['print ' pdf_path '/dtr2d_2Dmap' num2str(nk) ' -loose -dpng -r300'])
pause(1)
end

return

figure(2), clf
set(gcf, 'PaperUnits','centimeters', 'PaperPosition', 1*[0 0 figsize],'PaperSize', figsize);
axh2 = axes('position',[.15 .15 .4 .4]);
axh3 = axes('position',[.15 .55 .4 .4]);
axh4 = axes('position',[.55 .15 .4 .4]);
cla(axh2), cla(axh3), cla(axh4)
hold(axh2,'on'), hold(axh3,'on'), hold(axh4,'on')
axis(axh2,'square'), axis(axh3,'square'), axis(axh4,'square')
%for nk = 1:sz(3)
    for nj = nj_range
        for ni = ni_range
            if dps.mask(ni,nj,nk)
                m = squeeze(dps.m(ni,nj,nk,:))';
                s0 = dps.s0(ni,nj,nk);
                if s0 > s0_threshold*s0max
                    dtr2d = dtr2d_m2dtr2d(m);
                    [n,par,perp,theta,phi,r2,w] = dtr2d_dist2par(dtr2d);
                    if n>0
                        xcos = cos(phi).*sin(theta);
                        ycos = sin(phi).*sin(theta);
                        zcos = cos(theta);

                        iso = tm_eigvals2iso([par perp perp]);
                        fa = tm_eigvals2fa([par perp perp]);

                        c.x = log10(iso);
                        c.y = log10(par./perp);
                        c.z = log10(r2);
                        c.ms = 5*ms_max*sqrt(w/s0max);
                        c.bright = fa;
                        c.r = abs(xcos);
                        c.g = abs(ycos);
                        c.b = abs(zcos);

                        for nc = 1:n
                            if w(nc) > w_threshold*s0
                                h2 = plot(axh2,c.x(nc),c.y(nc),'o','LineWidth',.01);
                                h3 = plot(axh3,c.x(nc),c.z(nc),'o','LineWidth',.01);
                                h4 = plot(axh4,c.z(nc),c.y(nc),'o','LineWidth',.01);
                                col = c.bright(nc)*[c.r(nc) c.g(nc) c.b(nc)];
                                set([h2; h3; h4],'MarkerSize',c.ms(nc),'Color',col,'MarkerFaceColor',col)
                            end
                        end
                        %pause(.01)
                    end
                end
             end
        end
    end
%end
set([axh2; axh3; axh4],'TickDir','out','TickLength',.03*[1 1],...
'FontSize',fs,'LineWidth',lw,'Box','on')

set(axh2,'XLim',[xmin xmax]+.2*(xmax-xmin)*[-1 1], 'YLim',[ymin ymax]+.2*(ymax-ymin)*[-1 1],...
'XTick',[-11:1:-8],'YTick',-2:2)
xlabel(axh2,'log(\itD\rm_{iso} / m^2s^-^1)','FontSize',fs)
ylabel(axh2,'log(\itD\rm_{||} / \itD\rm_{\perp})','FontSize',fs)

set(axh3,'XLim',[xmin xmax]+.2*(xmax-xmin)*[-1 1], 'YLim',[zmin zmax]+.2*(zmax-zmin)*[-1 1],...
'XTick',[-11:1:-8],'YTick',0:.5:2.5,'XTickLabel','')
ylabel(axh3,'log(\itR\rm_{2} / s^-^1)','FontSize',fs)

set(axh4,'XLim',[zmin zmax]+.2*(zmax-zmin)*[-1 1], 'YLim',[ymin ymax]+.2*(ymax-ymin)*[-1 1],...
'XTick',[0:.5:2.5],'YTick',-2:2,'YTickLabel','')
xlabel(axh4,'log(\itR\rm_{2} / s^-^1)','FontSize',fs)

eval(['print ' pdf_path '/dtr2d_global -loose -dpdf'])

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





