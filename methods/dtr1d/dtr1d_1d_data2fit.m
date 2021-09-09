function m = dtr1d_1d_data2fit(signal, xps, opt, ind)
% function m = dtr1d_1d_data2fit(signal, xps, opt, ind)
%
% Size-shape-orientation diffusion tensor distribution

if (nargin < 4), ind = ones(size(signal)) > 0; end

bt_mx6 = xps.bt(ind,:);
tr = xps.tr(ind);
stemp = signal(ind);
stemp = abs(stemp);

dtr1d = dtr1d_proliferation(stemp, bt_mx6, tr, opt);
%dtr1d
%pause
dtr1d = dtr1d_extinction(stemp, bt_mx6, tr, dtr1d, opt);
m = dtr1d_dtr1d2m(dtr1d,opt);
%size(m)

if (opt.dtr1d.do_plot)
    figure(1), clf
    signal_fit = dtr1d_1d_fit2data(m, xps);
    %[~,s_ind] = sort(signal_fit,'descend');
    %semilogy(xps.b,signal,'.',xps.b,signal_fit,'o',xps.b,m(1)*weight,'x');
    plot(1:xps.n,signal,'o',1:xps.n,signal_fit,'x');
%     plot(ind,signal(ind),'o',ind,signal_fit(ind),'x');
%    plot(te,stemp,'o',te,signal_fit(ind),'x');
%    plot(sum(bt_mx6(:,1:3),2),stemp,'o',sum(bt_mx6(:,1:3),2),signal_fit(ind),'x');
    %set(gca,'YLim',m(1)*[.01 1.2])
    pause(0.05);
end