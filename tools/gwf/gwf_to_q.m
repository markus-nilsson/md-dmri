function q = gwf_to_q(gwf, rf, dt, opt)
% function q = gwf_to_q(gwf, rf, dt, opt)

if (nargin < 4), opt = []; end 

opt = gwf_opt(opt);

g_eff = gwf_to_g_eff(gwf, rf, dt);

q = msf_const_gamma(opt.gwf.nucleus) * cumsum( g_eff, 1 ) * dt;
