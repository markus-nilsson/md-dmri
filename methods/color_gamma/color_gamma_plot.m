function color_gamma_plot(S, xps, axh, axh2)
% function color_gamma_plot(S, xps, axh, axh2)

if (nargin < 4), axh2 = []; end

opt = mdm_opt();
opt = dti_euler_opt(opt);
opt = color_gamma_opt(opt);
opt = mplot_opt(opt);
xps = color_gamma_check_xps(xps);

% Customize options
opt.dti_euler.weight_wthresh = .5;
opt.color_gamma.weight_sthresh = .1;

% Prepare series for gamma fits
glob_ind = (1:xps.n)';
nfit = 0;
sub_ind = [];
sub_xps.fit_ind = [];

for nbdu = 1:xps.Nbdu
    ind = nbdu==xps.bdu_ind;
    
    temp_ind1 = glob_ind(ind);
    btemp1 = xps.b(ind);
    seriestemp1 = xps.s_ind(ind);
    [btemp1_unique,~,~] = uniquetol(btemp1,0.01);
    [~,~,seriestemp1_ind] = uniquetol(seriestemp1,0.01);

    Nrep = numel(btemp1)/numel(btemp1_unique);
    Nrep = 1; %One fit to all repeated measurements with same b_delta and u
    for nrep = 1:Nrep
        if Nrep > 1
            indrep = nrep==seriestemp1_ind;
            btemp = btemp1(indrep);
            temp_ind = temp_ind1(indrep);
        else
            btemp = btemp1;
            temp_ind = temp_ind1;
        end

        if all([sum(ind) > 2 all(btemp>0)])
            nfit = nfit + 1;
            sub_xps.fit_ind = [sub_xps.fit_ind; nfit*ones(size(btemp))];
            sub_ind = [sub_ind; temp_ind];
        end
    end
end

%[sub_xps.fit_ind sub_xps.b-xps.b(sub_ind) sub_xps.b_delta-xps.b_delta(sub_ind) sub_ind]

sub_S = S(sub_ind);
sub_xps.b = xps.b(sub_ind);
sub_xps.b_delta = xps.b_delta(sub_ind);
sub_xps.u = [xps.u(sub_ind,1) xps.u(sub_ind,2) xps.u(sub_ind,3)];

Nfit = max(sub_xps.fit_ind);

% DTI fit to find MD and max eigenvector
m     = dti_euler_1d_data2fit(S, xps, opt); 
S_fit = dti_euler_1d_fit2data(m, xps);

s0          = m(1);
lambdax     = m(2);
lambday     = m(3);
lambdaz     = m(4);
euler_alpha = angle(exp(1i*m(5)));
euler_beta  = angle(exp(1i*m(6)));
euler_gamma = angle(exp(1i*m(7)));

[rotmat,rotmatinv] = tm_euler_angles2rotmat(euler_alpha,euler_beta,euler_gamma);
dt_lambda = diag([lambdax, lambday, lambdaz]);
dt3x3 = rotmat*dt_lambda*rotmatinv;
dt = tm_3x3_to_tpars(dt3x3);

% Gamma fits
m = color_gamma_1d_data2fit(sub_S, sub_xps, opt); 
sub_Sfit = color_gamma_1d_fit2data(m, sub_xps);

% Clear, plot, and configure 
Smax = max(S(:));
bmax = max(xps.b(:));

cla(axh); hold(axh, 'off');
cla(axh2); hold(axh2, 'off');
hold(axh,'on')
hold(axh2,'on')


for nfit = 1:Nfit
    ind = nfit == sub_xps.fit_ind;
    Stemp = sub_S(ind);
    Sfittemp = sub_Sfit(ind);
    btemp = sub_xps.b(ind);
    bdtemp = sub_xps.b_delta(ind); bdtemp = bdtemp(1);
    utemp = sub_xps.u(ind,:); utemp = utemp(1,:);
    col = abs(utemp);
        
    [~,sort_ind] = sort(btemp);
    ph1 = semilogy(axh2,btemp(sort_ind)+bmax*bdtemp,Sfittemp(sort_ind),'-');
    ph2 = semilogy(axh2,btemp(sort_ind)+bmax*bdtemp,Stemp(sort_ind),'o');
    set([ph1; ph2],'Color',col)
end

for nfit = 1:Nfit
    ind = nfit == sub_xps.fit_ind;
    bdtemp = sub_xps.b_delta(ind); bdtemp = bdtemp(1);
    utemp = sub_xps.u(ind,:); utemp = utemp(1,:);
    col = abs(utemp);
        
    m_temp =  m(1,(1:3)+3*(nfit-1));
    
    p2costheta = .5*(3*sum(utemp.*dt.lambda33vec)^2 - 1);
    xtemp = 2/3*(p2costheta+.5) + bdtemp;
    ph = plot(axh,xtemp,m_temp(2)/dt.iso,'o',xtemp,m_temp(3)/dt.iso^2,'x');
    set(ph,'Color',col)
end

set(axh2,'YScale','log','YLim',[max([.8*min(S(:)); .01*Smax]) 1.1*Smax],'XLim',bmax*[0 2],'XTick',round(bmax*[0 .5 1]/1e8)*1e8)
ylabel(axh2,'signal')
xlabel(axh2,'b / m^-^2s')

plot(axh,[0 1],1*[1 1],'k-')
plot(axh,[1; 2],[dt.lambda11; dt.lambda33]./dt.iso,'k-',[1; 2],[dt.lambda22; dt.lambda33]./dt.iso,'k-')
axis(axh,'tight')
ylim = get(axh,'YLim');
ylim = (ylim(2)-ylim(1))*[-.1 .1]+[ylim(1) ylim(2)];
ylim = ylim(2)*[-.1 1.1];
set(axh,'XLim',[-.1 2.1],'YLim',ylim,'XTick',[0 .5 1])
xlabel(axh,'P_2(cos\theta)')
ylabel(axh,'o D/MD, x \mu_2/MD^2')
title(axh,['FA=' num2str(dt.fa,2) ' v_1=(' num2str(dt.lambda33vec(1),2) ',' num2str(dt.lambda33vec(2),2) ',' num2str(dt.lambda33vec(3),2) ')'])

set([axh; axh2],'TickDir','out','TickLength',.02*[1 1])

if opt.color_gamma.do_weight
    wthresh = opt.color_gamma.weight_wthresh;
    sthresh = m(1)*opt.color_gamma.weight_sthresh;
    semilogy(axh2, [0; bmax*max(xps.bd_ind)],sthresh*[1; 1],'k--')
end

end