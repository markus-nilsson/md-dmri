function mfs_fn = dtd_covariance_4d_data2fit(s, mfs_fn, opt, ind)
% function mfs_fn = dtd_covariance_4d_data2fit(s, mfs_fn, opt, ind)
%
% s         - structure with two fields pointing to data (s.nii_fn and s.xps)
% mfs_fn    - model fit structure filename
% opt       - options (optional)
% ind       - singal indices used to fit the model (optional)

if (nargin < 3), opt = []; end
if (nargin < 4), ind = ones(s.xps.n,1) > 0; end

% supplement this directly to the data2fit function
xps = s.xps;


%   simple direct fitting
    function m = f1(signal)
        m = dtd_covariance_1d_data2fit(signal, xps, opt, ind);
    end


[e_bulk, ~] = tm_1x21_iso();

%   extra fitting performed:
%   redo fiton smoothed data if no fit was returned (m(1) == 0) or
%   if the bulk variance is below zero (often a sign something is
%   has gone wrong)
    function m = f2(signal, signal2)
        
        m = dtd_covariance_1d_data2fit(signal, xps, opt, ind);
        
        if (m(1) == 0) || (m(8:28) * e_bulk' < 0)
            m = dtd_covariance_1d_data2fit(signal2, xps, opt, ind);
        end
        
    end

% select fit strategy
if (opt.dtd_covariance.do_extra_fit)    
    opt.mio.fit_model.s_type = 'smooth';
    f = @f2;    
else
    f = @f1;
end

% run the model fit
mfs_fn = mio_fit_model(f, s, mfs_fn, opt);

end