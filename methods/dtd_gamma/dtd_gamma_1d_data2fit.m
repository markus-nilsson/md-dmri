function m = dtd_gamma_1d_data2fit(signal, xps, opt, ind)
% function m = dtd_gamma_1d_data2fit(signal, xps, opt, ind)
%
% m = [s0   d_iso mu2_iso mu2_aniso]
% m = [s0   MD    Vi      Va       ]

if (nargin < 4), ind = ones(size(signal)) > 0; end

if (isfield(xps, 's_ind') && opt.dtd_gamma.do_multiple_s0)
    ns = numel(unique(xps.s_ind)) - 1;
else
    ns = 0;
end

unit_to_SI = [max(signal+eps) 1e-9 (1e-9)^2*[1 1] ones(1,ns)];

% Convert local params to outside format.
    function m = t2m(t)
        % define model parameters
        s0          = t(1);
        d_iso       = t(2);
        mu2_iso     = t(3);
        mu2_aniso   = t(4);
        sw          = t((end-(ns - 1)):end);
        m = [s0 d_iso mu2_iso mu2_aniso sw] .* unit_to_SI;
    end

% Convert non weighted to weighted signal.
    function s = my_1d_fit2data(t,varargin)
        m = t2m(t);
        % signal
        s = dtd_gamma_1d_fit2data(m, xps);
        s = s(ind).*weight(ind);
    end

% Soft heaviside weighting function
% limit the fit to the initial slope
% sthresh: normalized signal threshold value [0.2]
% mdthresh: MD [1e-9]
% wthresh: width of transition from 1 to 0 [5]
% bthresh: b-value at transition
    function weight = weightfun(sthresh,mdthresh,wthresh)
        bthresh = -log(sthresh)/mdthresh;
        weight = .5*(1-erf(wthresh*(xps.b - bthresh)/bthresh));
    end

% Weight function that corrects for hetroscedacity due to different number
% of images being averaged in the powder avereaged signal
    function w = calc_weight_from_signal_samples()
        if ~isfield(xps, 'pa_w')
            w = ones(size(xps.b));
        else
            w = sqrt( xps.pa_w / max(xps.pa_w) );
        end
    end

% Guess and fitting bounds
m_lb = [opt.dtd_gamma.fit_lb 0.5 * ones(1,ns)];
m_ub = [opt.dtd_gamma.fit_ub 2.0 * ones(1,ns)];

m_lb(1) = m_lb(1) * max(signal+eps);
m_ub(1) = m_ub(1) * max(signal+eps);

m_lbz     = m_lb .* (m_lb > 0); % Avoid negative guess

t_lb      = m_lb./unit_to_SI;
t_ub      = m_ub./unit_to_SI;

r_thr = inf;

for i = 1:opt.dtd_gamma.fit_iters
    
    % initial fit with weighting using guess value of MD
    weight = ones(xps.n,1);
    
    if (opt.dtd_gamma.do_weight)
        weight = weightfun(opt.dtd_gamma.weight_sthresh,opt.dtd_gamma.weight_mdthresh,opt.dtd_gamma.weight_wthresh);
    end
    
    % Weight with 1/sqrt(n) so that LS-fit is weighted to 1/n propto 1/variance
    if (opt.dtd_gamma.do_pa_weight)
        weight = weight .* calc_weight_from_signal_samples();
    end
    
    % Create a random guess
    m_guess = msf_fit_random_guess(@dtd_gamma_1d_fit2data, signal, xps, m_lbz, m_ub, weight, opt.dtd_gamma.guess_iters);
    t_guess = m_guess./unit_to_SI;
    
    
    % Non-linear fit to data
    t = lsqcurvefit(@my_1d_fit2data, t_guess, [], signal(ind).*weight(ind), t_lb, t_ub,...
        opt.dtd_gamma.lsq_opts);
    
    m = t2m(t);
    
    % Redo the fit with weighting based on attenuation (and updated
    % estimate of MD).
    if (opt.dtd_gamma.do_weight)
        weight = weightfun(opt.dtd_gamma.weight_sthresh,m(2),opt.dtd_gamma.weight_wthresh);
        
        if opt.dtd_gamma.do_pa_weight
            weight = weight .* calc_weight_from_signal_samples();
        end
        
        t = lsqcurvefit(@my_1d_fit2data, t, [], signal(ind).*weight(ind), t_lb, t_ub,...
            opt.dtd_gamma.lsq_opts);
        
        m = t2m(t);
    end
    
    
    % Check residual
    s_fit = dtd_gamma_1d_fit2data(m, xps);
    
    res   = sum(((signal-s_fit).*weight).^2);
    
    if res < r_thr
        r_thr = res;
        m_keep = m;
    end
    
end

m = m_keep;

if (opt.dtd_gamma.do_plot)
    signal_fit = dtd_gamma_1d_fit2data(m, xps);
    semilogy(xps.b,signal,'.',xps.b,signal_fit,'o',xps.b,m(1)*weight,'x');
    set(gca,'YLim',m(1)*[.01 1.2])
    pause(0.05);
end

end




