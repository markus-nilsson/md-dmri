function m = ilt_1d_data2fit(signal, xps, opt, ind)
% function m = dtd_ndi_1d_data2fit(signal, xps, opt, ind)

if (nargin < 4), ind = ones(size(signal)) > 0; end

b = xps.b(ind,:);
b_delta = xps.b_delta(ind,:);
stemp = signal(ind);
    
dd = ilt_proliferation(stemp, b, b_delta, opt);
%dtd
%pause
dd = ilt_extinction(stemp, b, b_delta, dd, opt);
m = ilt_dd2m(dd,opt);
%size(m)
if (opt.ilt.do_plot)
    figure(1), clf
    signal_fit = ilt_1d_fit2data(m, xps);
    %[~,s_ind] = sort(signal_fit,'descend');
    %semilogy(xps.b,signal,'.',xps.b,signal_fit,'o',xps.b,m(1)*weight,'x');
    plot(1:xps.n,signal,'o',1:xps.n,signal_fit,'x');
    %set(gca,'YLim',m(1)*[.01 1.2])
    pause(0.05);
end