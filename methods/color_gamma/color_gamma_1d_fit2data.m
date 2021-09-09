function s = color_gamma_1d_fit2data(m, xps)
% function s = color_gamma_1d_fit2data(m, xps)

    function s = my_1d_fit2data(m, b)        
        s0    = m(1);         % Signal at no diff encoding
        d     = m(2);         % 1st moment
        mu2   = m(3);         % 2nd moment
        s = s0.*(1 + b.*mu2./d).^(-1*(d.^2./mu2));
        s = real(s);
    end


    s = zeros(size(xps.b));
    Nfit = max(xps.fit_ind);
    for nfit = 1:Nfit
        ind = nfit == xps.fit_ind;
        btemp = xps.b(ind);

        mtemp =  m(1,(1:3)+3*(nfit-1));    
        s(ind) = my_1d_fit2data(mtemp, btemp);
    end

end