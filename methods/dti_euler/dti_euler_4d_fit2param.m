function dps = dti_euler_4d_fit2param(mfs_fn, dps_fn, opt)
% function dps = dti_euler_4d_fit2param(mfs_fn, dps_fn, opt)

if (nargin < 2), dps_fn = []; end
if (nargin < 3), opt = []; end

opt = mdm_opt(opt);
mfs = mdm_mfs_load(mfs_fn);

% create parameter maps

mfs.s0          = mfs.m(:,:,:,1);
mfs.lambdax     = mfs.m(:,:,:,2);
mfs.lambday     = mfs.m(:,:,:,3);
mfs.lambdaz     = mfs.m(:,:,:,4);
mfs.euler_alpha = angle(exp(1i*mfs.m(:,:,:,5)));
mfs.euler_beta  = angle(exp(1i*mfs.m(:,:,:,6)));
mfs.euler_gamma = angle(exp(1i*mfs.m(:,:,:,7)));

sz = [1 1 1];
sz_temp = size(mfs.s0);
sz(1:numel(sz_temp)) = sz_temp;

mfs.dt_1x6 = zeros(sz(1), sz(2), sz(3), 6);

for nk = 1:sz(3)
    for nj = 1:sz(2)
        for ni = 1:sz(1)
            if mfs.mask(ni,nj,nk)==1
                alpha   = mfs.euler_alpha(ni,nj,nk);
                beta    = mfs.euler_beta(ni,nj,nk);
                gamma   = mfs.euler_gamma(ni,nj,nk);

                [rotmat,rotmatinv] = tm_euler_angles2rotmat(alpha,beta,gamma);

                lambdax = mfs.lambdax(ni,nj,nk);
                lambday = mfs.lambday(ni,nj,nk);
                lambdaz = mfs.lambdaz(ni,nj,nk);

                dt_lambda = diag([lambdax, lambday, lambdaz]);

                dt3x3 = rotmat*dt_lambda*rotmatinv;
                dt_1x6 = tm_3x3_to_1x6(dt3x3);

                mfs.dt_1x6(ni,nj,nk,:) = dt_1x6;
            end
        end
    end
end

% reshape help functions
sz_reshape  = msf_size(mfs.s0, 3); 
g_reshape = @(a,n) reshape(a, prod(sz_reshape(1:3)), n);
f_reshape = @(a,n) reshape(a, sz_reshape(1), sz_reshape(2), sz_reshape(3), n);

%Voigt format [xx, yy, zz, sqrt(2)*xy, sqrt(2)*xz, sqrt(2)*xz]
mfs = tm_dt_to_dps(g_reshape(mfs.dt_1x6, 6)*1e9, mfs, f_reshape, 0.0001);

dps = mfs; clear mfs;

if (~isempty(dps_fn)), mdm_dps_save(dps, dps.s, dps_fn, opt); end


