function s = dtd_ndi_1d_fit2data(m, xps)
% function s = dtd_ndi_1d_fit2data(m, xps)
%
% m = [s0 v_int v_csf lambda md_csf]
% 

s0     = m(1);
v_int  = m(2);
v_csf  = m(3);
lambda = m(4);
md_csf = m(5);

v_ext  = 1 - v_int;

ad_int = lambda;
rd_int = 0;

% md_ec = lambda/3 * (3 - 2 * v_ic) = lambda (1 - 2/3 * v_int)
md_ext = (1 - 2/3 * v_int) * lambda;


% ----------------- int
md_int      = (ad_int + 2 * rd_int) / 3;
d_delta_int = (ad_int - rd_int) / (3 * md_int);

a_int  = 3*xps.b.*md_int.*xps.b_delta.*d_delta_int + eps;

s_int = exp(-xps.b.*md_int).*exp(a_int/3).*...
    sqrt(pi)/2.*real(gammainc(a_int,1/2)./sqrt(a_int));


% --------------- ext
s_ext = exp(-xps.b * md_ext);


% -------------- csf
s_csf = exp(-xps.b * md_csf);


s = s0 * ( ...
    (0 + v_csf) * s_csf + ...
    (1 - v_csf) * (v_int * s_int + v_ext * s_ext) ); 