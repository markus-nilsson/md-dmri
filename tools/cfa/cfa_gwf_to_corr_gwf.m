function [gwf_corr, gwf_true, gwf_mxwl] = cfa_gwf_to_corr_gwf(gwf, pos, B0, do_plot)

if nargin < 4
    do_plot = 0;
end


Gx = gwf(:,1);
Gy = gwf(:,2);
Gz = gwf(:,3);


Gxx = Gz.*Gz;
Gxy = zeros(size(Gxx));
Gxz = -2*Gx.*Gz;
Gyy = Gz.*Gz;
Gyz =  -2*Gy.*Gz;
Gzz = 4*(Gx.*Gx + Gy.*Gy);


gwf_mxwl = zeros(size(gwf));

for i = 1:size(gwf,1)
    
    C = [
        Gxx(i) Gxy(i) Gxz(i);
        Gxy(i) Gyy(i) Gyz(i);
        Gxz(i) Gyz(i) Gzz(i);
        ];
    
    gwf_mxwl(i,:) = (pos * C) / (4 * B0);
    
end

gwf_true = gwf+gwf_mxwl;

gwf_corr = gwf-gwf_mxwl;

if do_plot
    subplot(4,1,1)
    plot(gwf)
    title('in')
    
    subplot(4,1,2)
    plot(gwf_mxwl)
    title('concomitant')
    
    subplot(4,1,3)
    [~, tmp] = cfa_gwf_to_corr_gwf(gwf_corr, pos, B0, 0);
    plot(tmp)
    title('true after correction')
    
    subplot(4,1,4)
    plot(gwf-tmp)
    title('in - true')
    
end



