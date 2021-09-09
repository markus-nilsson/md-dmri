function gwf_plot_mech_spectra(gwf, rf, dt, opt)
% function gwf_plot_mech_spectra(gwf, rf, dt, opt)
%
% Plot mechanical spectra to check for potential resonances
%
% gwf - n x (1, 2, or 3)  [gradient as executed by amplifier]
% rf  - n x 1             [effect of RF pulses, either 1 or -1]
% dt  - 1 x 1             [time step]
% opt - option structure

if (nargin < 4), opt = []; end
opt = gwf_opt(opt);

pars = gwf_to_pars(gwf, rf, dt);

for c = 1:size(gwf, 2)
    
    % zero fill before power computation
    tmp = gwf(:, c);
    tmp = cat(1, zeros(size(tmp)), tmp, zeros(size(tmp)));
    tmp = cat(1, zeros(size(tmp)), tmp, zeros(size(tmp)));
    tmp = cat(1, zeros(size(tmp)), tmp, zeros(size(tmp)));
    
    ps = abs(fftshift(fft(tmp * dt))).^2;
    f  = linspace(-1/dt, 1/dt, numel(ps)) / 2;
    
    area(f, ps * 1e-9, ...
          'FaceAlpha', opt.gwf.gwf_facealpha(c), ...
        'EdgeColor', opt.gwf.edge_col{c}, ...
        'FaceColor', opt.gwf.col{c}, ...
        'LineWidth', opt.gwf.gwf_linew, ...
        'LineStyle', opt.gwf.gwf_linestyle{c}); hold on;
end

xlim([0 1] * max(opt.gwf.f_max, 2 * pars.gwf_spectral_trace_rms_norm));
xlabel('f [Hz]');
ylabel('Enc power');
box off;
set(gca,'tickdir', 'out', 'ticklength', [0.03 0.05]);
set(gca,'linewidth', 2);
set(gca,'ytick', []);
title('Power spectrum of g(t)');