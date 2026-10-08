function m = vasco16_1d_data2fit(signal, xps, opt, ind)
% function m = vasco16_1d_data2fit(signal, xps, opt, ind)

if (nargin < 3), opt = struct; end
if (nargin < 4), ind = ones(size(signal)) > 0; end

opt = vasco16_opt(opt);

unit_to_SI = [max(signal) 1e-6 1 1e-9 1e-9 1];

    function m = t2m(t) % convert local params to outside format
        
        % define model parameters
        s0          = t(1);
        D_tissue    = t(2); 
        vd2         = t(3);
        f_blood     = t(4);
        D_blood     = opt.vasco16.dblood / unit_to_SI(4);
        w           = t(5);
        
        m = [s0 vd2 f_blood D_blood D_tissue w] .* unit_to_SI;
    end

    function s = my_1d_fit2data_with_penalty(t,varargin)
        
        m = t2m(t);

        % calculate smooth heaviside regularization term
        vd = sqrt(max(m(2), 0));
        nterm       = xps.n/30;
        lambda1     = opt.vasco16.reg_lambda;
        sigma1_neg  = opt.vasco16.reg_vd_lb;
        sigma1_pos  = opt.vasco16.reg_vd_ub;
        delta       = opt.vasco16.reg_delta_vd;
        gaussterm1  = 1-0.5*(tanh((vd-sigma1_neg)/delta) - ...
            tanh((vd-sigma1_pos)/delta));
        regterm1    = lambda1 .* gaussterm1 .* nterm;

        % make a signal plus a reg term
        s = vasco16_1d_fit2data(m, xps);
        
        s = [s(:); regterm1];
        
    end

% S0, D, vd, f
t_guess   = opt.vasco16.fit_guess ./ unit_to_SI([1 5 2 3 6]);
t_lb      = opt.vasco16.fit_lb ./ unit_to_SI([1 5 2 3 6]);
t_ub      = opt.vasco16.fit_ub ./ unit_to_SI([1 5 2 3 6]);

% perform the fit
t = lsqcurvefit(@my_1d_fit2data_with_penalty, t_guess, [], [signal(ind);0], ...
    t_lb, t_ub, opt.vasco16.lsq_opts);

m = t2m(t);



% potentially plot the result
if (opt.vasco16.do_plot)
    signal_fit = vasco16_1d_fit2data(m, xps);
    
    ind_i{1} = (xps.alpha2 == 0) & ind;
    ind_i{2} = (xps.alpha2 >  0) & ind;
    t = {'FC', 'NC'};
    
    clf; set(gcf,'color','white');
    
    for c = 1:2
        subplot(1,2,c);
        semilogy(...
            xps.b(ind_i{c}) * 1e-6, signal(ind_i{c}),'x',...
            xps.b(ind_i{c}) * 1e-6, signal_fit(ind_i{c}),'o-');
        ylim( [0.7 1] * max(signal));
        title(t{c});
    end
    pause(0.05);
end


end
