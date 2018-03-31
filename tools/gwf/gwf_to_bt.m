function bt = gwf_to_bt(gwf, rf, dt, opt)
% function bt = gwf_to_bt(gwf, rf, dt)
%
% gwf - gradient waveform of size N x 3
% rf  - effect of rf pulses (range -1 to 1), size N x 1
% dt  - time step of waveform
%
% Following notation in Westin et al (2016) NeuroImage 135

if (nargin < 4) || (~isfield(opt, 'do_interpolate')), opt.do_interpolate = 1; end

gwf_check(gwf, rf, dt);

% numerical integration of q^2 requires some temporal resolution
% in order to avoid bias
if (dt > 1e-4) && (opt.do_interpolate ~= 0)% 2do: replace with soft limit
    [gwf,rf,dt] = gwf_interpolate(gwf, rf, dt, 16);
end

% compute q and the bt
q = gwf_to_q(gwf, rf, dt);

bt = q' * q * dt;

