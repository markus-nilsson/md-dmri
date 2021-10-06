function fn = ut_mio(c_ut)
% function fn = ut_mio(c_ut)
%
% Run unit tests on the files in this package

if (nargin == 0), fn = 6; return; end

switch (c_ut)
    
    case 1
        fn = 'mio_pad.m';
        
        I = zeros(10,10,10);
        
        I2 = mio_pad(I, [1 2 3]);
        
        if (~all(size(I2) == [12 14 16])), error('%s, ut_mio test %i', fn, c_ut); end
        
        I3 = mio_pad(I2, -[1 2 3]);
        
        if (~all(size(I3) == size(I))), error('%s, ut_mio test %i, step2', fn, c_ut); end
        
    case {2,3,4,5}
        fn = 'mio_volume_loop.m';
        
        opt.verbose = 0;
        
        I = ones(11,12,13,14);
        M = I(:,:,:,1) > 0;
        
        % allow test with and without parpool
        try % start parpool outside this function to have it run in parfor mode
            tmp = gcp('nocreate');
            n_workers = tmp.NumWorkers;
        catch
            n_workers = 1;
        end
        
        switch (c_ut)
            case 2
                opt.mio.no_parfor = 1;
                P = mio_volume_loop(@sum, I, M, opt);
                if (~all(P(:) == 14)), error('%s, ut_mio test %i', fn, c_ut); end
            case 3
                opt.mio.no_parfor = 1;
                P = mio_volume_loop(@(x,y) sum(x) + sum(y), I, M, opt, I);
                if (~all(P(:) == 14*2)), error('%s, ut_mio test %i', fn, c_ut); end
            case 4
                if (n_workers == 1), error('%s, ut_mio test %i; run parpool(x) first to test such functions', fn, c_ut); end
                P = mio_volume_loop(@sum, I, M, opt);
                if (~all(P(:) == 14)), error('%s, ut_mio test %i', fn, c_ut); end
                
            case 5
                if (n_workers == 1), error('%s, ut_mio test %i; run parpool(x) first to test such functions', fn, c_ut); end
                P = mio_volume_loop(@(x,y) sum(x) + sum(y), I, M, opt, I);
                if (~all(P(:) == 14*2)), error('%s, ut_mio test %i', fn, c_ut); end
                
        end
        
        
    case 6
        fn = 'mio_mask_threshold.m';

        % make phantom
        I = repmat(phantom(128), 1, 1, 128);
        I = cat(4, zeros(size(I)), I, zeros(size(I)));
        
        % expect this
        M_exp = mio_mask_fill(I(:,:,:,2) > 0);
        M_exp = mio_mask_expand(M_exp);
        
        opt.mask.b0_ind = 2;
        
        M = mio_mask_threshold(I, opt);
        
        % test that it works
        if (sum(M(:)) == 0)
            error('%s, ut_mio test %i, step 1', fn, c_ut); 
        end
        
        if (any(M(:) ~= M_exp(:)))
            error('%s, ut_mio test %i, step 2', fn, c_ut); 
        end
        
        
        % check arguments
        M = mio_mask_threshold(I, opt, 1);
        
        if (sum(M(:)) ~= 0)
            error('%s, ut_mio test %i, step 3', fn, c_ut); 
        end
        
        M = mio_mask_threshold(I, opt, 0, 1);
        
        if (sum(M(:)) ~= 0)
            error('%s, ut_mio test %i, step 4', fn, c_ut); 
        end

        
end
