function m = dtd_1d_data2fit(signal, xps, opt, ind)
% function m = dtd_1d_data2fit(signal, xps, opt, ind)
%
% Size-shape-orientation diffusion tensor distribution

if (nargin < 4), ind = ones(size(signal)) > 0; end

bt_mx6 = xps.bt(ind,:);
stemp = signal(ind);
    
dtd = dtd_proliferation(stemp, bt_mx6, opt);
%dtd
%pause
dtd = dtd_extinction(stemp, bt_mx6, dtd, opt);
m = dtd_dtd2m(dtd,opt);
%size(m)
if (opt.dtd.do_plot)
    figure(1), clf
    signal_fit = dtd_1d_fit2data(m, xps);
    %[~,s_ind] = sort(signal_fit,'descend');
    %semilogy(xps.b,signal,'.',xps.b,signal_fit,'o',xps.b,m(1)*weight,'x');
    plot(1:xps.n,signal,'o',1:xps.n,signal_fit,'x');
    %set(gca,'YLim',m(1)*[.01 1.2])
    pause(0.05);
end