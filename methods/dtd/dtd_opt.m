function opt = dtd_opt(opt)
% function opt = dtd_opt(opt)
%
% Makes sure that all needed fields in the options structure are present

method = 'dtd';

opt.(method).present = 1;

opt.(method) = msf_ensure_field(opt.(method), 'tmp', 1); 
opt.(method) = msf_ensure_field(opt.(method), 'do_plot', 0);
opt.(method) = msf_ensure_field(opt.(method), 'ind_start', 1);
opt.(method) = msf_ensure_field(opt.(method), 'dmin', 5e-12);
opt.(method) = msf_ensure_field(opt.(method), 'dmax', 5e-9);
opt.(method) = msf_ensure_field(opt.(method), 'n_in', 2e2); % n_in: Number of nodes in NNLS inversion. [100 - 1000]
opt.(method) = msf_ensure_field(opt.(method), 'n_out', 20);
opt.(method) = msf_ensure_field(opt.(method), 'n_kill', 0);
opt.(method) = msf_ensure_field(opt.(method), 'n_proliferation', 20);
opt.(method) = msf_ensure_field(opt.(method), 'n_extinction', 20);
opt.(method) = msf_ensure_field(opt.(method), 'ofuzz', .1*2*pi);
opt.(method) = msf_ensure_field(opt.(method), 'dfuzz', .1);

opt.(method) = msf_ensure_field(opt.(method), 'fig_maps', ...
    {'s0','mdiso','msddelta','vdiso'});
opt.(method) = msf_ensure_field(opt.(method), 'fig_prefix', 'dtd');
opt.(method) = msf_ensure_field(opt.(method), 'fig_cmaps',{});
opt.(method) = msf_ensure_field(opt.(method), 'fig_ccol',{});
opt.(method) = msf_ensure_field(opt.(method), 'fig_ccolnorm',{});
opt.(method) = msf_ensure_field(opt.(method), 'do_clamping',1);

opt.(method) = msf_ensure_field(opt.(method), 'bin_disomin',[0 0 2]*1e-9);
opt.(method) = msf_ensure_field(opt.(method), 'bin_disomax',[2 2 5]*1e-9);
opt.(method) = msf_ensure_field(opt.(method), 'bin_dratiomin',[1 1 1]*eps);
opt.(method) = msf_ensure_field(opt.(method), 'bin_dratiomax',[1 1 1]/eps);
opt.(method) = msf_ensure_field(opt.(method), 'bin_sddeltamin',[.25; 0; 0]);
opt.(method) = msf_ensure_field(opt.(method), 'bin_sddeltamax',[1; .25; 1]);

opt.(method) = msf_ensure_field(opt.(method), 'odf_nnodes', 1000); %250, 500, 1000, 3994, or 15970
opt.(method) = msf_ensure_field(opt.(method), 'odf_watsonkappa', 0.05);