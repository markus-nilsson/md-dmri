function m = gamma_1d_data2fit(signal, xps, opt, ind)
% function m = gamma_1d_data2fit(signal, xps, opt, ind)
%
% m = [s0 d_iso mu2_iso mu2_aniso]

if (nargin < 4), ind = ones(size(signal)) > 0; end

if (isfield(xps, 's_ind'))
    ns = max(xps.s_ind) - 1;
else
    ns = 0;
end


unit_to_SI = [max(signal) 1e-9 (1e-9)^2*[1 1] ones(1,ns)];

    function m = t2m(t) % convert local params to outside format
        
        % define model parameters
        s0          = t(1);
        d_iso       = t(2);
        mu2_iso     = t(3);
        mu2_aniso   = t(4);
        
        sw          = t((end-(ns - 1)):end);
        

        m = [s0 d_iso mu2_iso mu2_aniso sw] .* unit_to_SI;
    end
                            
    function s = my_1d_fit2data(t,varargin)
        
        m = t2m(t);

        % signal
        s = gamma_1d_fit2data(m, xps);
        s = s(ind).*weight(ind);
                
    end

% soft heaviside weighting function
% limit the fit to the initial slope
% sthresh: normalized signal threshold value [0.2]
% mdthresh: MD [1e-9]
% wthresh: width of transition from 1 to 0 [5]
% bthresh: b-value at transition
    function weight = weightfun(sthresh,mdthresh,wthresh)
        
        bthresh = -log(sthresh)/mdthresh;
        weight = .5*(1-erf(wthresh*(xps.b - bthresh)/bthresh));
                        
    end

% Guesses and bounds
m_lb      = [0             1e-11           0 0      0.5 * ones(1,ns)];
m_ub      = [2*max(signal) 3e-9  (3e-9)^2*[1 1]     2.0 * ones(1,ns)];
m_guess   = [max(signal)   1e-9  (1e-9)^2*[.01 .01] 1.0 * ones(1,ns)];
                
t_guess   = m_guess./unit_to_SI;
t_lb      = m_lb./unit_to_SI;
t_ub      = m_ub./unit_to_SI;


% initial fit with weighting using guess value of MD
weight = ones(xps.n,1);
pa_weight = weight;

if (opt.gamma.do_weight)
    weight = weightfun(opt.gamma.weight_sthresh,opt.gamma.weight_mdthresh,opt.gamma.weight_wthresh);
end

% Weight with 1/sqrt(n) so that LS-fit is weighted to 1/n propto 1/variance
if (opt.gamma.do_pa_weight)
    pa_weight = sqrt( xps.pa_w / max(xps.pa_w) );
end

% Initiate the threshold residual for multiple iterations
r_thr = inf;

% Do fitting
try
    for i = 1:opt.gamma.fit_iter
    
        if opt.gamma.do_random_guess
            m_guess   = m_lb + (m_ub - m_lb) .* rand(size(m_lb));
            t_guess   = m_guess./unit_to_SI;
        end

        t = lsqcurvefit(@my_1d_fit2data, t_guess, [], signal(ind).*weight(ind).*pa_weight(ind), t_lb, t_ub,...
            opt.gamma.lsq_opts);

        m = t2m(t);

        % redo the fit with updated value of MD
        if (opt.gamma.do_weight)
            weight = weightfun(opt.gamma.weight_sthresh,m(2),opt.gamma.weight_wthresh);

            t = lsqcurvefit(@my_1d_fit2data, t_guess, [], signal(ind).*weight(ind).*pa_weight(ind), t_lb, t_ub,...
                opt.gamma.lsq_opts);
        end

        m = t2m(t);
        
          % Check residual
        s_fit = gamma_1d_fit2data(m, xps);
        
        res   = sum(((signal-s_fit).*weight).^2);
        
        if res < r_thr
            r_thr = res;
            m_keep = m;
        end
    
    end
    
    % Final result with lowest residual
    m = m_keep;

catch me
    warning('Fitting failed, returning zeros!')
    disp(me.message)
    m = [0 0 0 0];
end


if (opt.gamma.do_plot)
    signal_fit = gamma_1d_fit2data(m, xps);
    semilogy(xps.b,signal,'.',xps.b,signal_fit,'o',xps.b,m(1)*weight,'x');
    set(gca,'YLim',m(1)*[.01 1.2])
    pause(0.05);
end

end
