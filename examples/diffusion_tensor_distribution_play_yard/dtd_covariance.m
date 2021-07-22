

% Define diffusion tensors
dt1 = tm_1x3_to_1x6(1,0,[1 0 0]);
dt2 = tm_1x3_to_1x6(0.4,0.3,[1 0 0]);

dt = [dt1; dt2];

% Here, we expect a number of diffusion tensors, represented as a 
% matrix with M x 6 elements

% Calculate different moments of the diffusion tensor distribution
dt_m = mean(dt, 1);
dt_2m = mean(tm_1x6_to_1x21(dt), 1);
dt_m2 = tm_1x6_to_1x21(dt_m);

% Calculate the variance in diffusion tensors
C = dt_2m - dt_m2;

% Get basis functions for the projections
[E_bulk, E_shear] = tm_1x21_iso();
E_iso = tm_6x6_to_1x21( 1/3 * eye(6) ); 

% Calculate normalized variance metrics
C_MD = 1/1 * tm_inner(C, E_bulk) / tm_inner(dt_2m, E_bulk);
C_mu = 3/2 * tm_inner(dt_2m, E_shear) / tm_inner(dt_2m, E_iso);

C_M  = 3/2 * tm_inner(dt_m2, E_shear) / tm_inner(dt_m2, E_iso);
C_c  = C_M / C_mu;

disp([C_MD C_mu C_M C_c])

% Connection to MKi and MKa
Vi   = tm_inner(C, E_bulk);
Va   = (2/5) * ( tm_inner(C, E_shear) + tm_inner(dt_m2, E_shear) );

MD   = tm_md(dt_m); % Defined from the trace of the diffusion tensor
FA   = tm_fa(dt_m);
uFA  = sqrt(C_mu);

MD2  = tm_inner(dt_m2, E_bulk); % = MD^2 but here defined from outer product of diffusion tensor (not used as parameter map)

MKi  = 3 * Vi / MD2;
MKa  = 3 * Va / MD2;
MKt  = MKi + MKa;