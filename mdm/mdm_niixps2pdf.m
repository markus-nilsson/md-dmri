function mdm_niixps2pdf(s, opt)
% function mdm_niixps2pdf(s, opt)
% Quick viewing of the global signal and acquisition protocol.
% Input: s structure with fields s.nii_fn and s.xps
% Output: matlab figure and pdf file saved in same directory as s.nii_fn

xps_fn = mdm_fn_nii2xps(s.nii_fn);
xps = mdm_xps_load(xps_fn);
[I,~] = mdm_nii_read(s.nii_fn);
signal = squeeze(sum(sum(sum(I,1),2),3));
signal = signal/max(signal);

figsize = 8.3*[1 1.618];
figaspect = figsize(1)/figsize(2);

fs = 8;
lw = 1;
ms = 10;

figure(1), clf
set(gcf, 'PaperUnits','centimeters', 'PaperPosition', 1*[0 0 figsize],'PaperSize', figsize);

left = 0.15;
width = .85;
bottom = .08;
dbottom = (1-bottom)/7;
height = dbottom - .02;

if ~isfield(xps,'u')
    if isfield(xps,'theta')
        xps.u = zeros(xps.n,3);
        xps.u(:,1) = sin(xps.theta).*cos(xps.phi);
        xps.u(:,2) = sin(xps.theta).*sin(xps.phi);
        xps.u(:,3) = cos(xps.theta);
    end
end
if ~isfield(xps,'tr')
    xps.tr = xps.ts;
end


axh_s = axes('position',[left bottom+6*dbottom width height]);
ph_s = plot(1:xps.n,signal,'.');
axh_b = axes('position',[left bottom+5*dbottom width height]);
ph_b = plot(1:xps.n,xps.b/1e9,'.');
axh_bd = axes('position',[left bottom+4*dbottom width height]);
ph_bd = plot(1:xps.n,xps.b_delta,'.');
axh_btheta = axes('position',[left bottom+3*dbottom width height]);
ph_btheta = plot(1:xps.n,acos(xps.u(:,3))/pi*180,'.');
axh_bphi = axes('position',[left bottom+2*dbottom width height]);
ph_bphi = plot(1:xps.n,atan2(xps.u(:,2),xps.u(:,1))/pi*180,'.');
axh_te = axes('position',[left bottom+1*dbottom width height]);
ph_te = plot(1:xps.n,xps.te,'.');
axh_tr = axes('position',[left bottom+0*dbottom width height]);
ph_tr = plot(1:xps.n,xps.tr,'.');

set([axh_s; axh_b; axh_bd; axh_btheta; axh_bphi; axh_te; axh_tr],...
'XLim',xps.n*[-.05 1.05],'Box','off','TickDir','out','LineWidth',lw,'FontSize',fs)    
set([axh_s; axh_b; axh_bd; axh_btheta; axh_bphi; axh_te],'XTickLabel',[])    
set([ph_s; ph_b; ph_bd; ph_btheta; ph_bphi; ph_te; ph_tr],'LineWidth',3,'Color','k')    
set(axh_s,'YLim',max(signal)*[-.05 1.05])    
set(axh_b,'YLim',max(xps.b/1e9)*[-.05 1.05])    
set(axh_bd,'YLim',[-.55 1.05])    
set(axh_btheta,'YLim',180*[-.05 1.05])    
set(axh_bphi,'YLim',180*[-1.05 1.05])    
set(axh_te,'YLim',max(xps.te)*[-.05 1.05])    
set(axh_tr,'YLim',max(xps.tr(xps.tr<20))*[-.05 1.05]) 

ylabel(axh_s,'signal')
ylabel(axh_b,'b / 10^9 sm^{-2}')
ylabel(axh_bd,'b_\Delta')
ylabel(axh_btheta,'\Theta / º')
ylabel(axh_bphi,'\Phi / º')
ylabel(axh_te,'TE / s')
ylabel(axh_tr,'TR / s')
xlabel(axh_tr,'acqusition index')

[fpath,fname,~] = msf_fileparts(s.nii_fn);
fn = fullfile(fpath, [fname '.pdf']);
eval(['print ' fn ' -loose -dpdf'])

