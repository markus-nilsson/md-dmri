function m = color_gamma_1d_data2fit(S, xps, opt)
% function m = color_gamma_1d_data2fit(S, xps, opt)

unit_to_SI = [max(S+eps) 1e-9 (1e-9)^2];

m_guess   = [max(S+eps) 1e-9 1e-20];
m_lb      = [0.99*max(S+eps) 1e-11 -1e-19];
m_ub      = [1.01*max(S+eps) 3e-9 5e-18];
                
t_guess   = m_guess./unit_to_SI;
t_lb      = m_lb./unit_to_SI;
t_ub      = m_ub./unit_to_SI;

    function m = t2m(t) % convert local params to outside format
        
        % define model parameters
        s0    = t(1);         % Signal at no diff encoding
        d     = t(2);         % 1st moment
        mu2   = t(3);         % 2nd moment
        
        m = [s0 d mu2] .* unit_to_SI;
    end

    function s = my_1d_fit2data(t, b)
        m = t2m(t);
        
        s0    = m(1);         % Signal at no diff encoding
        d     = m(2);         % 1st moment
        mu2   = m(3);         % 2nd moment
        s = s0.*(1 + b.*mu2./d).^(-1*(d.^2./mu2));
        s = real(s).*weight;
    end
%options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt','Display','off');
options = optimoptions('lsqcurvefit','Algorithm','trust-region-reflective','Display','off');


Nfit = max(xps.fit_ind);
m_v = [zeros(1,3*Nfit)];
for nfit = 1:Nfit
    ind = nfit == xps.fit_ind;
    Stemp = S(ind);
    btemp = xps.b(ind);
    bdtemp = xps.b_delta(ind); bdtemp = bdtemp(1);
    utemp = xps.u(ind,:); utemp = utemp(1,:);
    col = abs(utemp);
    
%     [~,sort_ind] = sort(btemp);
%     ph = semilogy(axh2,btemp(sort_ind)+bmax*bdtemp,Stemp(sort_ind),'o');
%     set(ph,'Color',col)
    
    weight = ones(size(Stemp));
    t_temp = lsqcurvefit(@my_1d_fit2data, t_guess, btemp, Stemp.*weight,t_lb,t_ub,options);
    s_gamma = my_1d_fit2data(t_temp, btemp);
    m_temp = t2m(t_temp);

    wthresh = opt.color_gamma.weight_sthresh;
    sthresh = opt.color_gamma.weight_wthresh*m_temp(1);
    weight = .5*(erf(wthresh*(s_gamma - sthresh)/sthresh)+1);

    t_temp = lsqcurvefit(@my_1d_fit2data, t_guess, btemp, Stemp.*weight,t_lb,t_ub,options);
    weight = ones(size(Stemp));
    s_gamma = my_1d_fit2data(t_temp, btemp);
    m_temp = t2m(t_temp);
    
    m_v(1,(1:3)+3*(nfit-1)) = m_temp;
end

m = m_v;

end