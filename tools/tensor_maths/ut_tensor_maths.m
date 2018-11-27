function fn = ut_tensor_maths(c_ut)
% function fn = ut_tensor_maths(c_ut)
%
% if c_ut is not supplied, the function returns the number of unit tests

n_ut = 13;

if (nargin == 0), fn = ut_run_single(n_ut, mfilename); return; end


switch (c_ut)
    
    case {1,2}
        fn = {'tm_1x6_to_3x3.m', 'tm_3x3_to_1x6.m'};
        fn = fn{c_ut};

        n = [ -0.4632   -0.5463    0.6978 ];
        t = tm_1x3_to_1x6(2,1,n);
        
        if any(abs(tm_3x3_to_1x6(tm_1x6_to_3x3(t)) - t) > eps)
            error('%s: Voigt back and forth not working', fn);
        end
   
    case 3
        fn = 'tm_1x6_eigvals.m';
        
        n = 100;
        t_1x6 = zeros(n, 6);
        L_supertrue = zeros(n, 3);
        for c = 1:n
            
            d = diag([0.1 1.0 2.0]);
            r = tm_euler_angles2rotmat(1*c,2*c,3*c);
            t_3x3 = r * d * r';
            t_1x6(c,:) = tm_3x3_to_1x6(t_3x3);
            
            L_supertrue(c,:) = sort(diag(d), 'descend');
        end
        
        % check quickly computed values versus those calculated with 'eigs'
        [L_true, U_true] = tm_1x6_eigvals(t_1x6, 2); % eigs
        [L_fast, U_fast] = tm_1x6_eigvals(t_1x6, 1); % Cardano
        
        for c = 1:n
            if any(abs( L_supertrue(c,:) - L_true(c,:)) > 1e-10)
                error('%s: True eigvals by  not working', fn);
            end
        end
        
        for c = 1:n
            if any(abs( L_fast(c,:) - L_true(c,:)) > 1e-10)
                error('%s: Quick eigvals by Cardano not working', fn);
            end
        end
        
        for c = 1:n
            if any( abs(abs(sum(U_fast(c,:) .* U_true(c,:))) - 1) > 1e-5 )
                error('%s: Quick eigvecs by Cardano not working', fn);
            end
        end
        
    case 4
        fn = 'tm_fa.m';
        
        dt_1x6 = [1 0 0 0 0 0; 0 0 0 0 0 0];
        
        fa = tm_fa(dt_1x6);
        
        if ( any( abs(fa - [1 0]') > eps ) )
            error('%s: FA calculation not working', fn);
        end
        
        
    case 5
        fn = 'tm_tpars_to_1x6.m';
        
        % define b-value, direction (u) and b_delta
        b = 1.0;
        u = uvec_elstat(50,'froeling');
        b_delta = linspace(-0.5, 1.0, size(u, 1))';

        % compute b-tensor from the tensor parameters above
        bt = tm_tpars_to_1x6(b, b_delta, u);

        % check that we get the same parameter back
        b_delta_out = zeros(size(b_delta));
        for c = 1:size(bt, 1)
            tp = tm_1x6_to_tpars(bt(c,:));
            b_delta_out(c) = tp.delta;
        end
        
        if (any( abs(b_delta - b_delta_out) > 1e-10))
            error('%s, ut_tensor_maths test %i, b_delta error', fn, c_ut);
        end            
        
    case 6
        fn = 'tm_dt_to_dps.m';
        
        % define a simple diffusion tensor
        ad = 2.0;
        rd = 0.5;
        u  = [ 1 0 0 ];
        dt = tm_1x3_to_1x6(ad, rd, u);
        
        dps = tm_dt_to_dps(dt);
        
        if (( abs(dps.ad - ad) > 1e-10))
            error('%s, ut_tensor_maths test %i, ad error', fn, c_ut);
        end            

        if (( abs(dps.rd - rd) > 1e-10))
            error('%s, ut_tensor_maths test %i, rd error', fn, c_ut);
        end            

        if (any( abs(dps.u - u) > 1e-10))
            error('%s, ut_tensor_maths test %i, u error', fn, c_ut);
        end            
        
    case 7
        fn = 'tm_dt_to_dps.m';
        
        % simulate a map of diffusion tensors
        sz = [10 11 12];
        dt = tm_1x3_to_1x6(2,0.5,[1 0 0]);
        dt = repmat(dt, prod(sz), 1);
        
        % define the reshape function
        f = @(x,n) reshape(x, sz(1), sz(2), sz(3), n);
        
        dps = tm_dt_to_dps(dt, [], f);
        
        if (any(size(dps.FA) ~= sz))
            error('%s, ut_tensor_maths test %i, size error', fn, c_ut);
        end   
        
        
    case 8
        fn = 'tm_kt_to_dps.m';

        % simulate a diffusion tensor distribution
        d_iso = randn(1,1e3)' * 0.1 + 1.0;
        dt_dist = tm_1x3_to_1x6(d_iso / 3, d_iso / 3, repmat([1 0 0], numel(d_iso), 1));
        
        % compute the mean and covariance of the tensor distribution
        dt = mean(dt_dist, 1);
        ct = mean(tm_1x6_to_1x21(dt_dist),1) - tm_1x6_to_1x21(dt);
        
        % convert the covariance tensor its lesser form
        ct_6x6 = tm_1x21_to_6x6(ct);
        ct_1x15 = tm_6x6_to_1x15(ct_6x6);
        
        % compute the kurtosis parameters
        dps = tm_dt_to_dps(dt);
        dps = tm_kt_to_dps(ct_1x15, dps);
        
        % compute the true kurtosis
        md_dist = tm_md(dt_dist);
        MK_true = 3 * var(md_dist) / mean(md_dist).^2;
        
        if ( abs(MK_true - dps.MK) > 1e-4 )
            error('%s, ut_tensor_maths test %i, MK error', fn, c_ut);
        end
        
    case 9
        fn = 'tm_1x6_eigvals.m';
        
        [L, U] = tm_1x6_eigvals(zeros(1,6), 1);
        
        if (any(isnan(L)))
            error('%s, ut_tensor_maths test %i, eigval error for zero input', fn, c_ut);
        end        
        
        if (any(isnan(U)))
            error('%s, ut_tensor_maths test %i, eigvec error for zero input', fn, c_ut);
        end        
        
    case 10
        fn = 'tm_kt_to_dps.m';
        
        % simulate a map of diffusion tensors
        sz = [10 11 12];
        dt = repmat(zeros(1,6),  prod(sz), 1);
        kt = repmat(zeros(1,15), prod(sz), 1);
        
        % define the reshape function
        f = @(x,n) reshape(x, sz(1), sz(2), sz(3), n);
        
        dps = tm_dt_to_dps(dt, [], f);
        dps = tm_kt_to_dps(kt, dps, f);
        
        if (any(size(dps.MK) ~= sz))
            error('%s, ut_tensor_maths test %i, size error', fn, c_ut);
        end   
        
        if (any(isnan(dps.MK(:))))
            error('%s, ut_tensor_maths test %i, MK NaN error', fn, c_ut);
        end            
        
    case 11
        fn = 'tm_ct_to_dps.m';
        
        % simulate a diffusion tensor distribution with randomly sizes
        % isotropic tensors
        d_iso = randn(1,1e3)' * 0.1 + 1.0;
        dt_dist = tm_1x3_to_1x6(d_iso / 3 + 0.001, ...
            d_iso / 3, repmat([1 0 0], numel(d_iso), 1));
        
        % compute the mean and covariance of the tensor distribution
        dt = mean(dt_dist, 1);
        ct = mean(tm_1x6_to_1x21(dt_dist),1) - tm_1x6_to_1x21(dt);
        
        % compute the covariance parameters
        dps = tm_dt_to_dps(dt);
        dps = tm_ct_to_dps(ct, dps);
        
        % compute true values
        md_dist = tm_md(dt_dist);
        
        V_MD = var(md_dist);
        
        % compare to true parameters        
        if ( abs(dps.V_MD - V_MD) > 1e-4 )
            error('%s, ut_tensor_maths test %i, V_MD error', fn, c_ut);
        end  
        
        
    case 12
        fn = 'tm_ct_to_dps.m';
        
        % simulate another diffusion tensor distribution, with randomly
        % oriented sticks
        dt_dist = tm_1x3_to_1x6(2.0, 0.1, uvec_elstat(400, 'froeling'));
        dt_ex   = dt_dist(1, :); % pull out one example
        
        % compute the mean and covariance of the tensor distribution
        dt = mean(dt_dist, 1);
        ct = mean(tm_1x6_to_1x21(dt_dist),1) - tm_1x6_to_1x21(dt);
        
        % compute the covariance parameters
        dps = tm_dt_to_dps(dt);
        dps = tm_ct_to_dps(ct, dps);
        
        % compute true values: shear from a single tensor should be the
        % same as the shear computed from the tensor distribution
        dps_ex = tm_dt_to_dps(dt_ex); 
        V_shear_true = dps_ex.V_shear2;
        
        % compare to true parameters        
        if ( abs(dps.V_shear - V_shear_true) > 1e-4 )
            error('%s, ut_tensor_maths test %i, V_shear error', fn, c_ut);
        end         
        
    case 13 % test the image capabilities of tm_ct_to_dps
        fn = 'tm_ct_to_dps.m'; 
        
        % simulate a map of diffusion tensors
        sz = [10 11 12];
        dt = repmat(zeros(1,6),  prod(sz), 1);
        kt = repmat(zeros(1,21), prod(sz), 1);
        
        % define the reshape function
        f = @(x,n) reshape(x, sz(1), sz(2), sz(3), n);
        
        dps = tm_dt_to_dps(dt, [], f);
        dps = tm_ct_to_dps(kt, dps, f);
        
        if (any(size(dps.C_mu) ~= sz))
            error('%s, ut_tensor_maths test %i, size error', fn, c_ut);
        end   
        
        if (any(isnan(dps.C_mu(:))))
            error('%s, ut_tensor_maths test %i, C_mu NaN error', fn, c_ut);
        end            
        
        
end