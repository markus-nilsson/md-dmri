function fn = ut_dtd_covariance(c_ut)
% function fn = ut_dtd_covariance(c_ut)
%
% Run unit tests on the files in this package

% if (nargin == 0), fn = 1; return; end

n_ut = 3;

if (nargin == 0), fn = ut_run_single(n_ut, mfilename); return; end


switch (c_ut)
    
    case {1,2,3,4}
        fn = 'dtd_covariance_1d_fit2data.m';
        
        % generate a collection of dffusion tensors
        
        d_iso = randn(1,1e4) * 0.1e-9 + 1.0e-9;
        dt = zeros(numel(d_iso), 6);
        for c = 1:numel(d_iso)
            dt(c,:) = tm_1x3_to_1x6(1.3 * d_iso(c), d_iso(c), [1 0 0]);
        end
        for c = 1:numel(d_iso)
            dt(end+1,:) = tm_1x3_to_1x6(2.0, 0.1, [0 1 0]) * 1e-9;
            dt(end+1,:) = tm_1x3_to_1x6(1.5, 1.5, [0 1 0]) * 1e-9;
        end
        
        % compute diffusion tensor covariance
        dtd_cov = mean(tm_1x6_to_1x21(dt),1) - tm_1x6_to_1x21(mean(dt,1));
        dtd_cov = dtd_cov * 1e18; % convert to natural units (um2/ms)
        
        switch (c_ut)
            case 1
                % setup an experiment with LTE and PTE, expected b-vals 
                bt = cat(1, ...
                    tm_1x3_to_1x6(eps, 0.0,  uvec_tricosa), ...
                    tm_1x3_to_1x6(1.0, 0.0,  uvec_tricosa), ...
                    tm_1x3_to_1x6(2.0, 0.0,  uvec_tricosa), ...
                    tm_1x3_to_1x6(0.0, 0.50, uvec_tricosa), ...
                    tm_1x3_to_1x6(0.0, 1.00, uvec_tricosa)) * 1e9;     
            case 2
                % setup an experiment with LTE and PTE, extremely low b-vals
                bt = cat(1, ...
                    tm_1x3_to_1x6(eps, 0.0,  uvec_tricosa), ...
                    tm_1x3_to_1x6(0.3, 0.0,  uvec_tricosa), ...
                    tm_1x3_to_1x6(0.6, 0.0,  uvec_tricosa), ...
                    tm_1x3_to_1x6(eps, 0.0,  uvec_tricosa), ...
                    tm_1x3_to_1x6(0.0, 0.10, uvec_tricosa), ...
                    tm_1x3_to_1x6(0.0, 0.30, uvec_tricosa)) * 1e9 / 10;
            case 3
                % setup an experiment with LTE and STE, extremely low b-vals
                bt = cat(1, ...
                    tm_1x3_to_1x6(eps, 0.0, uvec_tricosa), ...
                    tm_1x3_to_1x6(0.3, 0.0, uvec_tricosa), ...
                    tm_1x3_to_1x6(0.6, 0.0, uvec_tricosa), ...
                    tm_1x3_to_1x6(0.1, 0.1, uvec_tricosa), ...
                    tm_1x3_to_1x6(0.2, 0.2, uvec_tricosa)) * 1e9 / 10;                 
        end
        
        xps = mdm_xps_from_bt(bt);
        
        xps.u = cat(1, uvec_tricosa, uvec_tricosa, uvec_tricosa, ...
            uvec_tricosa, uvec_tricosa, uvec_tricosa);
        
        % generate the signal
        s = mean(exp(-xps.bt * dt'), 2);
        
        % fit the model
        opt = dtd_covariance_opt;
        [m, ~, n_rank] = dtd_covariance_1d_data2fit(s, xps, opt);
        
        % pull out invariants
        dtd_mean_est = m(2:7)' * 1e9;   % convert to (um2/ms)^1
        dtd_cov_est = m(8:end)' * 1e18; % convert to (um2/ms)^2
        
        [E_bulk, E_shear] = tm_1x21_iso();
        
        % ---- do the checks ---
        
        % check that n_dims are as expected
        n_rank_expected = [21 21 16];
        if (n_rank ~= n_rank_expected(c_ut))
            error('%s, ut_dtd_covariance test %i, rank is wrong', fn, c_ut);
        end
        
        % check that the dimensionality is ok
        if (numel(dtd_cov_est) ~= numel(dtd_cov))
            error('%s, ut_dtd_covariance test %i, dtd cov numel wrong', fn, c_ut);
        end  
        
        % check the covariance tensor itself
        cov_tol(1) = 1e-1; % with high b-values, we know we make an error
        cov_tol(2) = 1e-2; % lte+pte with low b-values should be OK 
        cov_tol(3) = inf;  % lte+ste, cov cannot be estimated correctly
        if (any( abs(dtd_cov_est - dtd_cov) > cov_tol(c_ut)))
            error('%s, ut_dtd_covariance test %i, dtd cov estimate wrong', fn, c_ut);
        end
         
        % check that the bulk variance gets correctly estimated
        x = abs(tm_inner(dtd_cov - dtd_cov_est, E_bulk) / tm_inner(dtd_cov, E_bulk));
        x_tol = [15 1 1] * 1e-2; % we know there's an error for moderate b-values
        
        if (x > x_tol(c_ut))
            error('%s, ut_dtd_covariance test %i, bulk estimate wrong', fn, c_ut);
        end
        
        % check that the shear variance gets correctly estimated
        x = abs(tm_inner(dtd_cov - dtd_cov_est, E_shear) / tm_inner(dtd_cov, E_bulk));
        x_tol = [8 2 2] * 1e-2; % we know there's an error for moderate b-values
        
        if (x > x_tol(c_ut))
            error('%s, ut_dtd_covariance test %i, bulk estimate wrong', fn, c_ut);
        end
        
end
