function fn = ut_mdm(c_ut)
% function fn = ut_mdm(c_ut)
%
% Run unit tests on the files in this package

if (nargin == 0), fn = 3; return; end


switch (c_ut)
    
    case 1
        fn = 'mdm_nii_write.m, mdm_nii_read.m';
        
        tmp_fn = fullfile(msf_tmp_path, 'a.nii');
        
        s = [1 16 16 4];
        
        a = randn(s) + 1i * randn(s);
        
        
        mdm_nii_write(a, tmp_fn);
        
        o = mdm_nii_read(tmp_fn);
        msf_delete(tmp_fn);
        
        if (...
                (size(a,1) ~= size(o,1)) || ...
                (size(a,2) ~= size(o,2)) || ...
                (size(a,3) ~= size(o,3)) || ...
                (size(a,4) ~= size(o,4)))
            
            error('%s, ut_mdm test %i, dimension error', fn, c_ut);
        end
        
        if (sum(abs(a(:) - o(:))) > eps)
            error('%s, ut_mdm test %i, read/write different', fn, c_ut);
        end
        
        
    case 2
        fn = 'mdm_xps_from_bt.m';
        
        bt = 1e9 * [...
            0 0 0 0 0 0
            6 0 0 0 0 0;
            2 2 2 0 0 0;
            3 3 0 0 0 0];
        
        xps = mdm_xps_from_bt(bt);
        
        if (abs(diff(xps.b)) > eps)
            error('%s, ut_mdm test %i, xps.b error', fn, c_ut);
        end
        
        if (any( xps.b_delta - [0 1 0 -1/2]' > eps))
            error('%s, ut_mdm test %i, xps.b_delta error', fn, c_ut);
        end
        
        if (any(xps.b_eta > eps))
            error('%s, ut_mdm test %i, xps.b_eta error', fn, c_ut);
        end
        
        if (any(xps.bt ~= bt))
            error('%s, ut_mdm test %i, xps.bt error', fn, c_ut);
        end            

        if (any(xps.n ~= size(bt,1)))
            error('%s, ut_mdm test %i, xps.n', fn, c_ut);
        end       
        
        if (any(isnan(xps.b_delta)))
            error('%s, ut_mdm test %i, nan ins b_delta', fn, c_ut);
        end  
        
        
        
    case 3
        fn = 'mdm_pa_ind_from_xps.m, mdm_pa_ind_from_xps.m';
        
        ab = [0   1  2  3]' * 1e9;
        rb = [0   0  1  3]' * 1e9;
        nd = [10 10 16 60]';
        
        b  = (ab + 2 * rb);
        
        n = numel(ab);
        for c = 1:n
            xps_cell{c}.bt = tm_1x3_to_1x6(ab(c), rb(c), uvec_elstat(nd(c)));
            xps_cell{c}.n  = size(xps_cell{c}.bt,1);
        end
        
        xps = mdm_xps_merge(xps_cell);
        xps = mdm_xps_from_bt(xps.bt);
        
        [~,c_list, id_ind] = mdm_pa_ind_from_xps(xps);
        
        for c = c_list'
            if (sum(id_ind == c) ~= nd(c))
                error('%s, ut_mdm test %i, mdm_pa_ind_from_xps error', fn, c_ut);
            end
        end
        
        
        xps = mdm_xps_pa(xps);
        
        if (xps.n ~= numel(b))
            error('%s, ut_mdm test %i, mdm_pa_ind_from_xps error2', fn, c_ut);
        end
        
        if (any( abs(xps.b - b) > 1 ))
            error('%s, ut_mdm test %i, xps_pa error', fn, c_ut);
        end
                
end
