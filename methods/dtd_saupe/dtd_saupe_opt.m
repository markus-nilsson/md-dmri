function opt = dtd_saupe_opt(opt)
% function opt = dtd_saupe_opt(opt)
%
% Makes sure that all needed fields in the options structure are present

opt.dtd_saupe.present = 1;

opt.dtd_saupe = msf_ensure_field(opt.dtd_saupe, 'tmp', 1); 
opt.dtd_saupe = msf_ensure_field(opt.dtd_saupe, 'fig_maps', {'op'});
opt.dtd_saupe = msf_ensure_field(opt.dtd_saupe, 'fig_prefix', 'dtd_saupe');
opt.dtd_saupe = msf_ensure_field(opt.dtd_saupe, 'fig_cmaps',{'ufa'});
opt.dtd_saupe = msf_ensure_field(opt.dtd_saupe, 'fig_ccol',{'s1x6prim'});
opt.dtd_saupe = msf_ensure_field(opt.dtd_saupe, 'fig_ccolnorm',{'slambda33prim'});
