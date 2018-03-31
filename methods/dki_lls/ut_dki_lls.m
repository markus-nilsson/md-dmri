function fn = ut_dki_lls(c_ut)
% function fn = ut_dki_lls(c_ut)
%
% Run unit tests on the files in this package

n_ut = 2;

if (nargin == 0), fn = ut_run_single(n_ut, mfilename); return; end

switch (c_ut)
    
    case {1,2}
        fn = 'dki_lls_1d_fit2data.m';
        
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
        dtd_mean = mean(dt, 1);
        
        switch (c_ut)
            case 1
                % setup an experiment with exceptionally low b-values
                bt = cat(1, ...
                    tm_1x3_to_1x6(eps, 0.0,  uvec_tricosa), ...
                    tm_1x3_to_1x6(1.0, 0.0,  uvec_tricosa), ...
                    tm_1x3_to_1x6(2.0, 0.0,  uvec_tricosa)) * 1e9 / 10;
            case 2
                % setup an experiment with exceptionally normal b-values
                bt = cat(1, ...
                    tm_1x3_to_1x6(eps, 0.0,  uvec_tricosa), ...
                    tm_1x3_to_1x6(1.0, 0.0,  uvec_tricosa), ...
                    tm_1x3_to_1x6(2.0, 0.0,  uvec_tricosa)) * 1e9;
        end
        
        xps = mdm_xps_from_bt(bt);
        xps.u = cat(1, uvec_tricosa, uvec_tricosa, uvec_tricosa);
        
        % generate the signal
        s = mean(exp(-xps.bt * dt'), 2);
        
        % fit the model
        opt = dki_lls_opt;
        m = dki_lls_1d_data2fit(s, xps, opt);
        
        % pull out invariants
        dt_est = m(2:7)';  % convert to (um2/ms)^1
        dk_est = m(8:end)'; % convert to (um2/ms)^2
        
        dps_est = tm_kt_to_dps(dk_est, tm_dt_to_dps(dt_est));
        dps_exp = tm_ct_to_dps(dtd_cov, tm_dt_to_dps(dtd_mean));
        
        
        % ---- do the checks ---
        
        % mean diffusion
        x = abs( (dps_est.MD - dps_exp.MD) / dps_exp.MD );
        x_tol(1) = 1e-2;
        x_tol(2) = 1e-2; 
        
        if (x > x_tol(c_ut))
            error('%s, ut_dtd_covariance test %i, MD estimate wrong', fn, c_ut);
        end
        
        % kurtosis
        x = abs( (dps_est.MK - dps_exp.MKt) / dps_exp.MKt );
        x_tol(1) = 2e-2;
        x_tol(2) = 5e-2; % we know there's an error for moderate b-values
        
        if (x > x_tol(c_ut))
            error('%s, ut_dtd_covariance test %i, MD estimate wrong', fn, c_ut);
        end        

        1;
        
end
