function gwf_plot_spectra(gwf, rf, dt, opt)
% function gwf_plot_spectra(gwf, rf, dt, opt)
%
% Plot the encoding spectra for x, y, and z directions
%
% gwf - n x (1, 2, or 3)  [gradient as executed by amplifier]
% rf  - n x 1             [effect of RF pulses, either 1 or -1]
% dt  - 1 x 1             [time step]
% opt - options structure

if (nargin < 4), opt = []; end
opt = gwf_opt(opt);

% compute spectrum
[gwf_ps, f] = gwf_power_spectrum(gwf, rf, dt, opt);

pars = gwf_to_pars(gwf, rf, dt);


% PLOT THE SPECTRA
% --------------------------
for c = 1:size(gwf, 2)
    
    area(f, gwf_ps(:,c) * 1e-9, ...
        'FaceAlpha', opt.gwf.gwf_facealpha(c), ...
        'EdgeColor', 'black', ...
        'FaceColor', opt.gwf.col{c}, ...
        'LineWidth', opt.gwf.gwf_linew); hold on;
end

xlim([0 1] * max(opt.gwf.f_max, 2 * pars.gwf_spectral_trace_rms_norm));
xlabel('f [Hz]');
ylabel('Enc power');
box off;
set(gca,'tickdir', 'out', 'ticklength', [0.03 0.05]);
set(gca,'linewidth', 2);
set(gca,'ytick', []);
title('Power spectrum of q(t)');






