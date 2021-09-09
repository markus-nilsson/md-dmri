function m = dtd_smr_1d_data2fit(signal, xps, opt, ind)
% function m = dtd_smr_1d_data2fit(signal, xps, opt)
%
%
% s0      = m(1);
% f       = m(2);
% di_s    = m(3);
% di_z    = m(4);
% dd_z    = m(5);
% p20     = m(6);
% p21r    = m(7);
% p21i    = m(8);
% p22r    = m(9);
% p22i    = m(10);
% t2_s    = m(11);
% t2_z    = m(12);
% ssr     = m(13);

if (nargin < 3), opt = dtd_smr_opt(); end
if (nargin < 4), ind = ones(size(signal)) > 0; end


%%% Normalization
%
ms = max(signal);
%             1     2       3       4       5       6       7       8       9       10       11     12
%             s0    fs      di_s    di_z    dd_z    p20     p21r    p21i    p22r    p22i    t2_s    t2_z
unit_to_SI = [ms    1       1e-9    1e-9    1       1       1       1       1       1       1e-3    1e-3];
%
maxp       = sqrt(5 / (4*pi)); % Not strictly necessary to enforce

%%% Set bounds
%           1       2       3       4       5        6      7       8       9       10       11     12
%           s0      fs      di_s    di_z    dd_z    p20    p21r    p21i    p22r    p22i      t2_s   t2_z
t_lb      = [0      eps     0.07    0.2    -0.4634 -maxp  -maxp   -maxp   -maxp   -maxp      30     30  ];
t_ub      = [40     1-eps   1.33    4       0.8636  maxp   maxp    maxp    maxp    maxp      300    1e3];

% Handle fixing (for NRV plots)
if (isfield(opt, 'f_min') && isfield(opt, 'f_max'))
    t_lb(2) = opt.f_min;
    t_ub(2) = opt.f_max;
end

lambda = mean(signal);

%%% Fitting function
    function s = my_1d_fit2data(t,varargin)
        
        % m2t
        m = t .* unit_to_SI;
                
        % signal prediction
        s = dtd_smr_1d_fit2data(m, xps);        
        
        % Penalties for keeping both da/r_z within [0.2 4]
        %
        p_factor = 1e1;
        %
        da_z = t(4) * (1 + 2 * t(5));
        dr_z = t(4) * (1 - 1 * t(5));
        %
        penalty_ah =  exp(max(0,  p_factor * (da_z - t_ub(4)))) - 1;
        penalty_rh =  exp(max(0,  p_factor * (dr_z - t_ub(4)))) - 1;
        penalty_al =  exp(max(0,  p_factor * (t_lb(4) - da_z))) - 1;
        penalty_rl =  exp(max(0,  p_factor * (t_lb(4) - dr_z))) - 1;
        %
        penalty = sum([penalty_ah penalty_rh penalty_al penalty_rl]);
        
        % Compose signal
        s = [s(ind); sum(penalty) * lambda];
    end

% Perform fitting iteratively
r = Inf;
for c_rep = 1:opt.n_rep
    
    % Possibly provide an initial guess
    if (isempty(opt.init_guess))
        g   = t_lb + rand(size(t_lb)) .* (t_ub - t_lb); % guess
    else
        g = opt.init_guess;
    end
    %
    warning off;
    [t_tmp, r_tmp] = lsqcurvefit(@(t,varargin) my_1d_fit2data(t), g, [], ...
        [signal(ind); 0], t_lb, t_ub, opt.lsq_opts);
    warning on;
    
    if (r_tmp < r)
        r = r_tmp;
        t = t_tmp;
    end
end
%
m_tmp = t .* unit_to_SI;
%
s_fit = dtd_smr_1d_fit2data(m_tmp, xps);
ssr   = sum((signal - s_fit).^2);
%
m = [m_tmp ssr];

end