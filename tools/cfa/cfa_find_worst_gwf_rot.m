function [R_out, wgwf] = cfa_find_worst_gwf_rot(gwf, rf, dt, ips, mode, opt)

if nargin < 6
    opt = optimset('fminsearch');
    opt.MaxFunEvals = 150;
    opt.MaxIter     = 150;
    opt.TolX        = 1e-3;
    opt.TolFun      = 1e-3;
    opt.n_repeat    = 3;   % custom field that needs to be added manually
end


thr = inf;

for i = 1:opt.n_repeat
    
    x0 = rand(1,3)*pi;
    
    x = fminsearch(@(x0) wf_eval_func(x0), x0, opt);
    
    c = wf_eval_func(x);
    if c < thr
        thr = c;
        xout = x;
    end
    
end


R_out = cfa_euler_ang_to_rotmat(xout(1), xout(2), xout(3));

wgwf  = gwf*R_out;



    function c = wf_eval_func(v)
        
        R = cfa_euler_ang_to_rotmat(v(1), v(2), v(3));
        
        [cc, cs, cp] = cfa_maxwell_bias(gwf*R, rf, dt, ips);
        
        switch mode
            case 1
                c = sum(cc(:));
            case 2
                c = sum(cs(:));
            case 3
                c = sum(cp(:));
        end
        
    end

end




