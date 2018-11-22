function fn = ut_dtd_covariance(c_ut)
% function fn = ut_dtd_covariance(c_ut)
%
% Run unit tests on the files in this package

% if (nargin == 0), fn = 1; return; end

n_ut = 8;

if (nargin == 0), fn = ut_run_single(n_ut, mfilename); return; end


switch (c_ut)
    
    case {1,2,3}
        fn = 'dtd_covariance_1d_fit2data.m';
        
        % SUBSTRATE DEFINITION: generate a collection of dffusion tensors
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
        
        
        % PROTOCOL DEFINITION
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
        dtd_mean_est = m(2:7) * 1e9;   % convert to (um2/ms)^1
        dtd_cov_est = m(8:end) * 1e18; % convert to (um2/ms)^2
        
        [E_bulk, E_shear] = tm_1x21_iso();
        
        % ---- do the checks ---
        
        % check that n_dims are as expected
        n_rank_expected = [21 21 16];
        if (n_rank ~= n_rank_expected(c_ut))
            error('%s, ut_dtd_covariance test %i, rank is wrong (%i vs %i)', ...
                fn, c_ut, n_rank, n_rank_expected(c_ut));
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
        x = abs(tm_inner(dtd_cov - dtd_cov_est, E_shear) / tm_inner(dtd_cov, E_shear));
        x_tol = [8 2 2] * 1e-2; % we know there's an error for moderate b-values
        
        if (x > x_tol(c_ut))
            error('%s, ut_dtd_covariance test %i, shear estimate wrong', fn, c_ut);
        end
        
    case {4,5,6,7,8}
        fn = 'dtd_covariance_1d_fit2data.m';
        
        % SUBSTRATE DEFINITION: generate a collection of dffusion tensors
        s0 = 1;
        switch (c_ut)
            
            case {4,5,6} % CSF
                dt = tm_1x3_to_1x6(3.0, 3.0, [1 0 0]) * 1e-9;
                MD_exp = 3;
                MD_tol = 0.05;
                
                MKa_exp = 0;
                MKa_tol = 0.1;
                
                MKi_exp = 0;
                MKi_tol = 0.1;
                
                
                switch (c_ut)
                    case 4
                        S0_exp = 1;
                        S0_tol = 0.02;
                        
                    case 5                        
                        S0_exp = 10000;
                        S0_tol = 0.02 * S0_exp;

                    case 6
                        S0_exp = 0.0001;
                        S0_tol = 0.02 * S0_exp;
                        
                end
                s0 = S0_exp;
                sn = s0/100; % snr = 100;


            case 7 % background
                
                s0 = 0;
                dt = tm_1x3_to_1x6(1.0, 1.0, [1 0 0]) * 1e-9;
                sn = 1/100;
                
                MD_exp = 0;
                MD_tol = 0.1;
                
                S0_exp = 0;
                S0_tol = 0.1;
                
                MKa_exp = 0;
                MKa_tol = 0.1;
                
                MKi_exp = 0;
                MKi_tol = 0.1;
                
                
            case 8 % normal WM voxel (approx)
                
                dt = cat(1, ...
                    tm_1x3_to_1x6(2.8, 0.1, [1 0 0]) * 1e-9, ...
                    tm_1x3_to_1x6(1.1, 1.0, [1 0 0]) * 1e-9);
                    
                sn = s0/40;
                
                MD_exp = mean(mean(dt(:,1:3))) * 1e9;
                MD_tol = 0.15;
                
                S0_exp = 1;
                S0_tol = 0.05;      
                
                MKa_exp = 0.94;
                MKa_tol = 0.15;
                
                MKi_exp = 0.0;
                MKi_tol = 0.15;
                
        end
        
        % PROTOCOL DEFINITION: typical "clinical" protocol
        bt = cat(1, ...
            tm_1x3_to_1x6(0.1, 0.0,  uvec_tricosa), ...   % lte
            tm_1x3_to_1x6(0.7, 0.0,  uvec_tricosa), ...   % lte
            tm_1x3_to_1x6(1.4, 0.0,  uvec_tricosa), ...   % lte
            tm_1x3_to_1x6(2.1, 0.00, uvec_tricosa), ...   % lte
            tm_1x3_to_1x6(2.8, 0.00, uvec_tricosa), ...   % lte
            tm_1x3_to_1x6(0.0, 1.00, uvec_tricosa), ...   % pte
            tm_1x3_to_1x6(0.0, 0.50, uvec_tricosa), ...   % pte
            tm_1x3_to_1x6(0.1, 0.1, uvec_tricosa), ...    % ste
            tm_1x3_to_1x6(0.4, 0.4, uvec_tricosa), ...    % ste
            tm_1x3_to_1x6(0.7, 0.7, uvec_tricosa)) * 1e9; % ste            
        
        xps = mdm_xps_from_bt(bt); 
        
        % generate the signal and add noise
        s = s0 * mean(exp(-xps.bt * dt'), 2);
        s = sqrt( (s + sn * randn(size(s))).^2 + (sn * randn(size(s))).^2 );
        
        % fit the model with regularization
        opt = dtd_covariance_opt(mdm_opt);
        opt.dtd_covariance.do_regularization = 1;
        m = dtd_covariance_1d_data2fit(s, xps, opt);
        
        % debugging by plotting
        if (0) 
            dtd_covariance_plot(s, xps, gca, [], opt);
        end
        
        % pull out display parameters
        dps = dtd_covariance_1d_fit2param(m, [], opt);
        
        f_test = @(t,v,tol) (~isnan(t)) && abs(t - v) > tol;
        
        error_detected = 0;
        
        opt.verbose = 1;
        
        if (f_test(MD_exp, dps.MD, MD_tol))
            msf_log(sprintf('%s, ut_dtd_covariance test %i, md estimate wrong (%1.2f vs %1.2f)', ...
                fn, c_ut, MD_exp, dps.MD), opt);
            error_detected = 1;
        end

        if (f_test(S0_exp, dps.s0, S0_tol))
            msf_log(sprintf('%s, ut_dtd_covariance test %i, s0 estimate wrong (%1.2f vs %1.2f)', ...
                fn, c_ut, S0_exp, dps.s0), opt);
            error_detected = 1;
        end
        
        if (f_test(MKa_exp, dps.MKa, MKa_tol))
            msf_log(sprintf('%s, ut_dtd_covariance test %i, MKa estimate wrong (%1.2f vs %1.2f)', ...
                fn, c_ut, MKa_exp, dps.MKa), opt);
            error_detected = 1;
        end
        
        if (f_test(MKi_exp, dps.MKi, MKi_tol))
            msf_log(sprintf('%s, ut_dtd_covariance test %i, MKi estimate wrong (%1.2f vs %1.2f)', ...
                fn, c_ut, MKi_exp, dps.MKi), opt);
            error_detected = 1;
        end        
        
        if (error_detected)
            error('%s, ut_dtd_covariance test %i, problem found', fn, c_ut);
        end        
        

        
end
