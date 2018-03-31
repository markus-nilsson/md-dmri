function fn = ut_run_single(n_ut, fun_ut)
% function fn = ut_run_single(n_ut)
%
% Run unit test for single component

if (all(ischar(fun_ut))), fun_ut = eval(['@(x)' fun_ut '(x)']); end

tmp = dbstack;

switch (tmp(end).name)
    
    case 'ut_run'
        fn = n_ut;
    
    otherwise
        
        fn = cell(1,n_ut);
        for c_ut = 1:n_ut
            fn{c_ut} = fun_ut(c_ut);
        end
        
end
