function opt = ilt_opt(opt)
% function opt = dtd_ndi_opt(opt)
%
% Makes sure that all needed fields in the options structure are present

opt.ilt.present = 1;

opt.ilt = msf_ensure_field(opt.ilt, 'tmp', 1); 
opt.ilt = msf_ensure_field(opt.ilt, 'do_plot', 0);
opt.ilt = msf_ensure_field(opt.ilt, 'ind_start', 2);
opt.ilt = msf_ensure_field(opt.ilt, 'dmin', 1e-11);
opt.ilt = msf_ensure_field(opt.ilt, 'dmax', 5e-9);
opt.ilt = msf_ensure_field(opt.ilt, 'n_in', 2e2); % n_in: Number of nodes in NNLS inversion. [100 - 1000]
opt.ilt = msf_ensure_field(opt.ilt, 'n_out', 50);
opt.ilt = msf_ensure_field(opt.ilt, 'n_kill', 0);
opt.ilt = msf_ensure_field(opt.ilt, 'n_proliferation', 20);
opt.ilt = msf_ensure_field(opt.ilt, 'n_extinction', 20);
opt.ilt = msf_ensure_field(opt.ilt, 'dfuzz', .1);

opt.ilt = msf_ensure_field(opt.ilt, 'fig_maps', {'s0','D'});
opt.ilt = msf_ensure_field(opt.ilt, 'fig_prefix', 'ilt');