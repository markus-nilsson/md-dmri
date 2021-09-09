function mfs_fn = mdm_data2fit_supp(fun_4d_data2fit, s, mfs_fn, opt, S)
% function mfs_fn = mdm_data2fit(fun_4d_data2fit, s, mfs_fn, opt)
%
% fun_4d_data2fit - model fit function
% s               - input data structure
% mfs_fn          - the model fit structure is written to mfs_fn
% opt             - options structure

if (nargin < 4), opt.present = 1; end

opt = mdm_opt(opt);

msf_log(['Starting ' mfilename ' with ' char(fun_4d_data2fit)], opt);    

if (exist(mfs_fn, 'file') && (~opt.do_overwrite))
    disp(['Skipping, output file already exists: ' mfs_fn]); return;
end

if (~opt.do_data2fit)
    mfs_fn = '';
    return;
end

mfs_fn = fun_4d_data2fit(s, mfs_fn, opt, S);


