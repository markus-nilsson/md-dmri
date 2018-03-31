function fn = ut_gwf(c_ut)
% function fn = ut_gwf(c_ut)
%
% Run unit tests on the files in this package

n_ut = 2;

if (nargin == 0), fn = ut_run_single(n_ut, mfilename); return; end

switch (c_ut)
    
    case 1
        fn = 'gwf_to_bt.m';
        
        g_max = 200e-3;
        
        gwf = [...
            +1 +1 +0 -1 -1 +0 +0 +0 +0 +0 +0 +0 +0 +0 +0 ;
            +0 +0 +0 +0 +0 +1 +1 +0 -1 -1 +0 +0 +0 +0 +0 ;
            +0 +0 +0 +0 +0 +0 +0 +0 +0 +0 +1 +1 +0 -1 -1 ]' * g_max;
        
        dt = 1e-3;
        
        bt_exp = eye(3) * msf_const_gamma('1H')^2 * g_max^2 * (2*dt)^2 * (3*dt - 2*dt/3);
        
        rf = ones(size(gwf,1), 1);
        
        bt = gwf_to_bt(gwf, rf, dt);
        
        % accept 0.01% error in the b-value
        if (any(abs(bt - bt_exp) ./ (bt_exp + 0.0001 * trace(bt_exp)) > 0.001))
            error('%s, ut_gwf test %i, bt calculation error', fn, c_ut);
        end

    case 2
        fn = 'gwf_analysis.m'; % will now only check that it executes
        
        g_max = 200e-3;
        
        gwf = [...
            +1 +1 +0 -1 -1 +0 +0 +0 +0 +0 +0 +0 +0 +0 +0 ;
            +0 +0 +0 +0 +0 +1 +1 +0 -1 -1 +0 +0 +0 +0 +0 ;
            +0 +0 +0 +0 +0 +0 +0 +0 +0 +0 +1 +1 +0 -1 -1 ]' * g_max;
        
        dt = 1e-3;
        
        rf = ones(size(gwf,1), 1);

        txt = gwf_analysis(gwf, rf, dt);
               
        
        
end
