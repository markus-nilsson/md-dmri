function [gwf, rf, dt] = cfa_gwf_example(mode)
% function [gwf, rf, dt] = cfa_gwf_example(mode)
% Container for some example waveforms in the CFA framework.

switch mode
    case 1 % SE-SDE in x
        gwf = [
            0 1 1 1 1 1 0 0 0 1 1 1 1 1 0;
            0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
            0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
            ]'*.08;
        
        rf  = [1 1 1 1 1 1 0 0 0 -1 -1 -1 -1 -1 -1]';
        
        dt = 3e-3;
        
    case 2 % SE-DDE in x and y, respectively (no error if not rotated)
        gwf = [
            0 1 1 0 -1 -1 0 0 0 0 0 0  0  0 0;
            0 0 0 0  0  0 0 0 0 1 1 0 -1 -1 0;
            0 0 0 0  0  0 0 0 0 0 0 0  0  0 0
            ]'*.08;
        
        rf  = [1 1 1 1 1 1 0 0 0 -1 -1 -1 -1 -1 -1]';
        
        dt = 6e-3;
        
    case 3 % SE-DDE in x and z, respectively (significant error w/o rot)
        gwf = [
            0 1 1 0 -1 -1 0 0 0 0 0 0  0  0 0;
            0 0 0 0  0  0 0 0 0 0 0 0  0  0 0;
            0 0 0 0  0  0 0 0 0 1 1 0 -1 -1 0;
            ]'*.08;
        
        rf  = [1 1 1 1 1 1 0 0 0 -1 -1 -1 -1 -1 -1]';
        
        dt = 6e-3;
        
    case 4 % Optimal LTE when using long EPI
        gwf = [
            0 0 0 0 0 0 0 0  0  0  0 0 0 0 0 0 0 0;
            0 1 1 1 1 1 1 0 -1 -1 -1 0 0 0 1 1 1 0;
            0 0 0 0 0 0 0 0  0  0  0 0 0 0 0 0 0 0;
            ]'*.08;
        
        rf  = [1 1 1 1 1 1 1 1 1 1 1 1 0 -1 -1 -1 -1 -1]';
        
        dt = 3e-3;
        
    case 5 % Asym Bipolar
        d1 = 5;
        d2 = 25;
        dp = 5;
        t1 = ones(d1,1);
        t2 = ones(d2,1);
        p1 = zeros(dp,1);
        
        gwf = [0; t1; p1; t2; 0; -t2; p1; -t1; 0];
        
        gwf = [gwf 0*gwf 0*gwf]*0.08;
        
        rf  = [1; t1; p1; -t2; -1; -t2; p1; t1; 1];
        
        dt  = .6e-3;
        
    case 6 % Sym Bipolar
        d = 15;
        dp = 5;
        t1 = ones(d,1);
        p1 = zeros(dp,1);
        
        gwf = [0; t1; p1; t1; 0; -t1; p1; -t1; 0];
        
        gwf = [gwf 0*gwf 0*gwf]*0.08;
        
        rf  = [1; t1; p1; -t1; -1; -t1; p1; t1; 1];
        
        dt  = .6e-3;
        
    case 7 %long short
        ratio = 10;
        long = 100;
        t1 = ones(long,1)*1/ratio;
        t2 = ones(long/ratio,1);
        p = zeros(10,1);
        
        gwf = [0; t1; p; t2; 0];
        
        gwf = [gwf 0*gwf 0*gwf]*0.08;
        
        rf = [1; ones(size(t1)); p; -ones(size(t2)); -1];
        
        dt = 1e-3;
        
    case 8 %Asym OGSE
        p1 = 5;
        p2 = 3;
        t1 = cos(linspace(0,pi*p1, 100*p1))';
        t2 = cos(linspace(0,pi*p2, 100*p2))';
        p = zeros(50,1);
        gwf = [0; t1; p; t2; 0];
        gwf = [gwf 0*gwf 0*gwf]*0.08;
        
        rf = [1; ones(size(t1)); p; -ones(size(t2)); -1];
        dt = .23e-3;
        
    case 9 % Quadratic nulling in 1D
        gwf = [
            0 1 1 1 0 -1 -1 -1 0 2 2 2 0 0 0 3 3 0;
            ]'*.08/3;
        gwf = [gwf gwf*0 gwf*0];
        
        rf  = [0 1 1 1 1 1 1 1 1 1 1 1 1 0 -1 -1 -1 -1]';
        
        dt = 3e-3;
        
end












