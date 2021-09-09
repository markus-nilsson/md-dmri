function res = dtr2d_spen_4d_data2fit(s, mfs_fn, opt)
% function mfs_fn = dtr2d_4d_data2fit(s, o, opt)

if (nargin < 3), opt = []; end

res = -1;

ind = opt.dtr2d.ind_start:s.xps.n;

%Verify the xps
%dti_euler_mic_check_xps(s.xps);

% Loop over the volume and fit the model
xps = s.xps; % this appears to improve parallel performance
%f = @(signal) dtr2d_1d_data2fit(signal, xps, opt, ind);

%dummy = mio_fit_model(f, s, mfs_fn, opt);
% Read and reformat data
[I,h]  = mdm_nii_read(s.nii_fn);
M      = mdm_mask_load(s, opt);

h.scl_slope = 1;
h.scl_inter = 0;

% Disallow model fits to complex data
if (any(imag(I) ~= 0)), I = abs(I); end 

% Analyze and store output
%mfs.m       = mio_volume_loop(fun, I, M, opt);
n_param = 1 + 6*opt.dtr2d.n_out;
p = zeros(n_param, size(I,1), size(I,2), size(I,3));
for k = 1:size(I,3)
    for j = 1:size(I,2)
        if (any(M(:,j,k)))            
            for i = 1:size(I,1)
                if (M(i,j,k) == 0), continue; end
                if (all(I(i,j,k,:) == 0)), continue; end
                xps_temp = xps;
                te_temp = xps.te + xps.dte(:,j); %Correction for the different TE per SPEN line
                xps_temp.te = te_temp;
                signal = squeeze(I(i,j,k,:));
                m = dtr2d_1d_data2fit(signal, xps_temp, opt, ind);
                p(:,i,j,k) = m;
                %[i j k]
                %m
            end                
        end
    end
end

mfs.m = permute(p, [2 3 4 1]);

mfs.mask    = M;
mfs.nii_h   = h;

% Save data
mfs_fn = mdm_mfs_save(mfs, s, mfs_fn, opt);


res = 1;