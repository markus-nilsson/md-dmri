function fn = ut_mdm(c_ut)
% function fn = ut_mdm(c_ut)
%
% Run unit tests on the files in this package

if (nargin == 0), fn = 7; return; end


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
        
        
    case 4 
        fn = 'mdm_xps_from_gdir.m';
        
        % write a gdir file
        tmp_fn = fullfile(msf_tmp_path, 'tmp.txt');
        fid = fopen(tmp_fn, 'w');
        fprintf(fid, '0,0,0,0\n1, 0, 0, 1000 \n0, 1, 0, 1000\n0,0,1,1000');
        fclose(fid);
        
        % read it, convert to xps
        xps = mdm_xps_from_gdir(tmp_fn);
        xps2 = mdm_xps_from_gdir(tmp_fn, [], 0);
        xps3 = mdm_xps_from_gdir(tmp_fn, [], -0.5);
        
        msf_delete(tmp_fn);
        rmdir(fileparts(tmp_fn));
        
        b = [0 1 1 1]' * 1e9;

        if (any( abs(xps.b - b) > 1 ))
            error('%s, ut_mdm test %i, xps.b error', fn, c_ut);
        end

        if (any(isnan(xps.u(:))))
            error('%s, ut_mdm test %i, xps.u error', fn, c_ut);
        end
            
        if (any(any( abs(xps.u - [0 0 0; eye(3)]) > eps)))
            error('%s, ut_mdm test %i, xps.u error', fn, c_ut);
        end
        
        if (any(abs(xps2.b_delta) > 1e-10))
            error('%s, ut_mdm test %i, xps.b_delta error', fn, c_ut);
        end
        
        if (any(abs(xps3.b_delta - (-0.5)) > 1e-10))
            error('%s, ut_mdm test %i, xps.b_delta error', fn, c_ut);
        end
        
            
    case 5
        fn = 'mdm_xps_from_bval_bvec.m';
        
        % write b-val and b-vec files
        o = msf_tmp_path();
        bval_fn = fullfile(o, 'bval.txt');
        fid = fopen(bval_fn, 'w');
        fprintf(fid, '1 1000 1000 1000');
        fclose(fid);
        
        bvec_fn = fullfile(o, 'bvec.txt');
        fid = fopen(bvec_fn, 'w');
        fprintf(fid, '1 1 0 0\n 0 0 1 0\n 0 0 0 1');
        fclose(fid);
        
        % read it, convert to xps
        xps1 = mdm_xps_from_bval_bvec(bval_fn, bvec_fn);
        xps2 = mdm_xps_from_bval_bvec(bval_fn, bvec_fn, 0);
        xps3 = mdm_xps_from_bval_bvec(bval_fn, bvec_fn, -0.5);
        
        msf_delete(bval_fn);
        msf_delete(bvec_fn);
        rmdir(fileparts(bval_fn));
        
        b = [1/1000 1 1 1]' * 1e9;

        if (any( abs(xps1.b - b) > 1 ))
            error('%s, ut_mdm test %i, xps.b error', fn, c_ut);
        end

        if (any(isnan(xps1.u(:))))
            error('%s, ut_mdm test %i, xps.u error', fn, c_ut);
        end
            
        if (any(any( abs(xps1.u - [1 0 0; eye(3)]) > eps)))
            error('%s, ut_mdm test %i, xps.u error', fn, c_ut);
        end
        
        if (any(abs(xps2.b_delta) > 1e-10))
            error('%s, ut_mdm test %i, xps.b_delta error #1', fn, c_ut);
        end
        
        if (any(abs(xps3.b_delta - (-0.5)) > 1e-10))
            error('%s, ut_mdm test %i, xps.b_delta error #2', fn, c_ut);
        end        
        
        
    case 6
        fn = 'mdm_gwf_read.m, mdm_gwf_write.m';
        
        % define gradient waveform
        g0 = cat(1, zeros(1,3), ones(10,3), zeros(1,3));
        
        % write gwf
        gwf_fn = fullfile(msf_tmp_path(), 'gwf.txt');
        
        mdm_gwf_write(g0, gwf_fn);
        
        g1 = mdm_gwf_read(gwf_fn);
        
        % delete files
        msf_delete(gwf_fn);
        rmdir(fileparts(gwf_fn));
        
        if ...
                (size(g0,1) ~= size(g1,1)) || ...
                (size(g0,2) ~= size(g1,2)) || ...
                (any( abs(g1(:) - g0(:)) > eps))
            error('%s, ut_mdm test %i, read/write error', fn, c_ut);
        end     
        
    case 7
        fn = 'mdm_xps_info.m';
        
        gwf = zeros(100,3);
        rf = cat(1, ones(50,1), -ones(50,1));
        dt = 1e-3;
        
        xps = gwf_to_pars(gwf, rf, dt);
        
        msg = mdm_xps_info(xps);
        
        if (isempty(msg))
            error('%s, ut_mdm test %i, no msg generated', fn, c_ut);
        end
            
end
