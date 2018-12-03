function h = gwf_plot_all(gwf, rf, dt, opt)
% function h = gwf_plot(gwf, rf, dt, opt)
%
% gwf - n x (1, 2, or 3)  [gradient as executed by amplifier]
% rf  - n x 1             [effect of RF pulses, either 1 or -1]
% dt  - 1 x 1             [time step]
% opt - option structure

if (nargin < 4), opt = []; end, opt = gwf_opt(opt);

msf_clf();
h(1) = subplot(2,2,1); gwf_plot(gwf, rf, dt, opt);
h(2) = subplot(2,2,2); gwf_plot_analysis(gwf, rf, dt, opt);
h(3) = subplot(2,2,3); gwf_plot_spectra(gwf, rf, dt, opt);
h(4) = subplot(2,2,4); gwf_plot_mech_spectra(gwf, rf, dt, opt);


