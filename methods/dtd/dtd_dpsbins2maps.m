function axh_v = dtd_dpsbins2maps(figh,dps,plim)

if nargin < 3
    plim.mdiso = 1.2e-9*[0 1];
    plim.msddelta = 1*[0 1];
    plim.vdiso = 2.5e-19*[0 1];
    plim.vsddelta = .15*[0 1];
    plim.cvdisosddelta = 1.5e-10*[-1 1];
end

figure(figh)

nk = 1;

Nparams = 6;
Nbins = numel(dps.bin);
papersize = 3*[Nparams Nbins+1];

left = 0; bottom = 0; width = 1/Nparams; height = 1/(Nbins+1); dleft = width; dheight = height;

s0max = max(dps.s0(:));
s0thresh = .05;
plim.s0 = s0max*[0 1];
    
nbin = 0;
axh_v = [];
axh = dtd_dpsbin2maps(dps);
axh_v = [axh_v; axh];
for nbin = 1:Nbins
    axh = dtd_dpsbin2maps(dps.bin{nbin});
    axh_v = [axh_v; axh];
end
set(axh_v,'YDir','normal')

cmap_hot = colormap(hot(64));
cmap_cool = [cmap_hot(:,3) cmap_hot(:,2) cmap_hot(:,1)];
cmap_hotcool = [flipud(cmap_cool); zeros(1,3); cmap_hot];
for n = 1:numel(axh_v), colormap(axh_v(n),cmap_hotcool), end
    
axis(axh_v,'square','off')

set(figh, 'PaperUnits','centimeters','PaperPosition', [0 0 papersize],'PaperSize', papersize); 

function axh_v = dtd_dpsbin2maps(dps)
    axh_v = [];
    
    im2d = squeeze(dps.s0(:,:,nk));
    mask2d = im2d > s0thresh*s0max;
    axh = axes('position',[left+0*dleft 1-(nbin+1)*dheight width height]);
    clim = max(plim.s0)*[-1 1];
    imagesc(im2d')
    set(axh,'CLim',clim)
    axh_v = [axh_v; axh];

    im2d = squeeze(dps.mdiso(:,:,nk)).*mask2d;
    clim = max(plim.mdiso)*[-1 1];
    axh = axes('position',[left+1*dleft 1-(nbin+1)*dheight width height]);
    imagesc(im2d')
    set(axh,'CLim',clim)
    axh_v = [axh_v; axh];

    im2d = squeeze(dps.msddelta(:,:,nk)).*mask2d;
    clim = max(plim.msddelta)*[-1 1];
    axh = axes('position',[left+2*dleft 1-(nbin+1)*dheight width height]);
    imagesc(im2d')
    set(axh,'CLim',clim)
    axh_v = [axh_v; axh];

    im2d = squeeze(dps.vdiso(:,:,nk)).*mask2d;
    clim = max(plim.vdiso)*[-1 1];
    axh = axes('position',[left+3*dleft 1-(nbin+1)*dheight width height]);
    imagesc(im2d')
    set(axh,'CLim',clim)
    axh_v = [axh_v; axh];

    im2d = squeeze(dps.vsddelta(:,:,nk)).*mask2d;
    clim = max(plim.vsddelta)*[-1 1];
    axh = axes('position',[left+4*dleft 1-(nbin+1)*dheight width height]);
    imagesc(im2d')
    set(axh,'CLim',clim)
    axh_v = [axh_v; axh];

    im2d = squeeze(dps.cvdisosddelta(:,:,nk)).*mask2d;
    clim = max(plim.cvdisosddelta)*[-1 1];
    axh = axes('position',[left+5*dleft 1-(nbin+1)*dheight width height]);
    imagesc(im2d')
    set(axh,'CLim',clim)
    axh_v = [axh_v; axh];
end

end