function txt = gwf_analysis(gwf, rf, dt, opt)
% function gwf_analysis(gwf, rf, dt, col)
%
% gwf - n x (1, 2, or 3)  [gradient as executed by amplifier]
% rf  - n x 1             [effect of RF pulses, either 1 or -1]
% dt  - 1 x 1             [time step]
% opt - options structure

if (nargin < 2), error('rf needed'); end
if (nargin < 3), error('dt needed'); end
if (nargin < 4), opt = []; end

opt = gwf_opt(opt);

pars = gwf_to_pars(gwf, rf, dt, opt);

txt = {...
    'GRADIENT WAVEFORM ANALYSIS', ...
    sprintf('|k_0| = %2.2f 1/mm', 1e-3 * sqrt(sum(pars.k0.^2))), ...
    sprintf('b = %2.2f ms/um^2, b_\\Delta = %1.2f, b_\\eta = %1.2f', pars.b * 1e-9, pars.b_delta, pars.b_eta), ...
    sprintf('|\\alpha|^2 = %1.0f s^2/mm^2 (flow comp)', pars.alpha_norm * 1e-6), ...
    sprintf('V_f = Tr(M_1) / Tr(b) =  %1.0f 1/s, [M_1]_\\Delta = %1.1f', pars.gwf_spectral_trace_rms_norm, pars.gwf_spectral_M1_delta), ...
    sprintf('Max slew rate = %2.0f, %2.0f, %2.0f T/m/s', pars.slew_rate_max(1), pars.slew_rate_max(2), pars.slew_rate_max(3)), ...
    sprintf('Max gradient = %2.0f, %2.0f, %2.0f mT/m', pars.gradient_max(1)*1e3, pars.gradient_max(2)*1e3, pars.gradient_max(3)*1e3), ...
    sprintf('Energy index = %2.2f (%2.2f, %2.2f, %2.2f)', sum(pars.energy_index * 1e4), pars.energy_index(1) * 1e4, pars.energy_index(2) * 1e4, pars.energy_index(3) * 1e4), ...
    sprintf('Maxwell index = %2.0f (mT/m)^2 ms', pars.maxwell_index * 1e9), ...
    };

if (nargout == 0)
    for c = 1:numel(txt)
        disp(strrep(txt{c}, '\\', '\'));
    end
end







