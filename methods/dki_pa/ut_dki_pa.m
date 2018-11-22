function fn = ut_dki_pa(c_ut)
% function fn = ut_dki_pa(c_ut)
%
% Run unit tests on the files in this package

if (nargin == 0), fn = 1; return; end

switch (c_ut)
    
    case 1
        
        % Test with different kinds of tensor distribution, test also
        % extended capabilities to deal with different b-tensor shapes
        fn = 'dki_pa_1d_fit2data.m';
        
        for c_case = 1:2
            
            switch (c_case)
                case 2
                    
                    % generate a normally distributed collection of 
                    % isotropic dffusion tensors
                    d_iso = randn(1,1e4) * 0.1e-9 + 1.0e-9;
                    dt = zeros(numel(d_iso), 6);
                    for c = 1:numel(d_iso)
                        dt(c,:) = tm_1x3_to_1x6(d_iso(c), d_iso(c), [1 0 0]);
                    end
                    
                case 1
                    
                    % generate randomly oriented anisotropic tensors
                    dt = tm_1x3_to_1x6(2e-9, 0.01e-9, ...
                        uvec_elstat(500, 'froeling'));
                    
            end
            
            % compute mean tensor and diffusion tensor covariance
            dtd_mean = mean(dt, 1);
            dtd_cov  = mean(tm_1x6_to_1x21(dt),1) - tm_1x6_to_1x21(mean(dt,1));
            
            % compute bulk and shear
            dps = tm_dt_to_dps(dtd_mean);
            dps = tm_ct_to_dps(dtd_cov, dps);
            
            % setup an experiment with LTE and PTE tensors
            sc = 0.05;
            
            bt = cat(1, ...
                tm_1x3_to_1x6(sc*eps, 0.0, uvec_tricosa), ...
                tm_1x3_to_1x6(sc*0.2, 0.0, uvec_tricosa), ...
                tm_1x3_to_1x6(sc*0.4, 0.0, uvec_tricosa), ...
                tm_1x3_to_1x6(sc*eps, 0.0, uvec_tricosa), ...
                tm_1x3_to_1x6(sc*0.0, sc*0.1, uvec_tricosa), ...
                tm_1x3_to_1x6(sc*0.0, sc*0.2, uvec_tricosa)) * 1e9;
            
            xps = mdm_xps_from_bt(bt);
            
            xps.u = cat(1, uvec_tricosa, uvec_tricosa, uvec_tricosa, ...
                uvec_tricosa, uvec_tricosa, uvec_tricosa);
            
            % generate the signal and powder average it
            s = mean(exp(-xps.bt * dt'), 2);
            
            [s_pa, xps_pa] = mdm_powder_average_1d(s, xps);
            
            % fit the model
            opt = dki_pa_opt();
            opt.dki_pa.do_include_b_tensor_anisotropy = 1;
            m = dki_pa_1d_data2fit(s_pa, xps_pa, opt);
            
            
            md_est = m(2) * 1e9;
            vi_est = m(3) * 1e18;
            va_est = m(4) * 1e18;
            
            md_exp = dps.MD * 1e9;
            vi_exp = dps.V_MD * 1e18;
            va_exp = 2/5 * dps.V_shear * 1e18; % signal variance 2/5 of shear
            
            
            % check that the estimated values agrees with expectations
            if (any( abs(md_est - md_exp) > 1e-4))
                error('%s, ut_dki_pa test %i, md estimate wrong', fn, c_ut);
            end

            if (any( abs(vi_est - vi_exp) > 1e-3))
                error('%s, ut_dki_pa test %i, variance estimate wrong', fn, c_ut);
            end
            
            if (any( abs(va_est - va_exp) > 2e-3))
                error('%s, ut_dki_pa test %i, shear variance wrong (%0.3f vs %0.3f)', fn, c_ut, va_est, va_exp);
            end
            
        end
        
        
        
end
