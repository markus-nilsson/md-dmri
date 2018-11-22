function m = gwf_maxwell_index(gwf, rf, dt)
% function m = gwf_maxwell_index(gwf, rf, dt)
% m is the "Maxwell index", as defined in 
% Szczepankiewicz and Nilsson, ISMRM 2018
% "Maxwell-compensated waveform design for asymmetric diffusion encoding"
% Download abstract at: https://goo.gl/vVGQq2
%
% Briefly, the Maxwell index can be use to guage the impact of concomitant
% fields on the signal. To estimate the signal error, please use
% Concomitant Field Analysis tools (CFA), by calling cfa_*.
%
% gwf must be a nx3 matrix that defines directions along the time dimension.
% rf  must be a nx1 matrix that defines the spin direction.

if (size(rf, 2) > 1)
    error('rf must be a nx1 matrix');
end

if (isempty(rf)), rf = gwf_to_rf(gwf); end

wf_Nx6 = tm_1x3_to_1x6(1, 0, gwf);
rf_Nx6 = repmat(rf, 1, 6);

M = tm_1x6_to_3x3( sum( wf_Nx6 .* rf_Nx6 ) * dt );

m = sqrt(trace(M*M));

