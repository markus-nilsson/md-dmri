function dps = dtd_covariance_4d_fit2param(mfs_fn, dps_fn, opt)
% function dps = dtd_covariance_4d_fit2param(mfs_fn, dps_fn, opt)
%
% Compute dps (display parameters structure) from the mfs (model fit
% structure) using functions tm_dt_to_dps and tm_ct_to_dps

if (nargin < 2), dfs_fn = []; end
if (nargin < 3), opt    = []; end

opt = dtd_covariance_opt(mdm_opt(opt));
mfs = mdm_mfs_load(mfs_fn);
sz  = msf_size(mfs.m(:,:,:,1), 3);

% reshape help functions
g = @(a,n) reshape(a, prod(sz(1:3)), n);
f = @(a,n) reshape(a, sz(1), sz(2), sz(3), n);

% Preliminary hack to get powder-averaged data into this structure
if (size(mfs.m, 4) == 4) % assume data was analyzed via the pa pipe
    
    % The dki_pa model yields MD, V_I, and V_A
    % Convert these to an isotropic dt and isotropic tensor covariance tensor
    % Note that V_A = 2/5 * < V_lambda[D] > 
    % [see Szczepankiewicz thesis Eq. 9]
    % We want V_lambda represented in the covariance tensor
  
    [E4_bulk, E4_shear] = tm_1x21_iso();
    E2_iso = [1 1 1 0 0 0]/3;
    
    h = @(x) x / tm_inner(x,x); % use normalized bases

    mfs.m = cat(4, ...
        mfs.m(:,:,:,1), ...
        f(g(mfs.m(:,:,:,2),1) .* repmat(h(E2_iso),   prod(sz(1:3)),1), 6), ...
        f(g(1/1 * mfs.m(:,:,:,3),1) .* repmat(h(E4_bulk),  prod(sz(1:3)),1), 21) + ...
        f(g(5/2 * mfs.m(:,:,:,4),1) .* repmat(h(E4_shear), prod(sz(1:3)),1), 21));
        
end

% compute display parameters
dps = dtd_covariance_1d_fit2param(g(mfs.m, 28), f, opt);

% mask after fitting
if (opt.dtd_covariance.do_post_fit_masking)
    
    % copute 
    X = [ones(mfs.s.xps.n,1) -mfs.s.xps.bt 1/2*tm_1x6_to_1x21(mfs.s.xps.bt)];
    I = mdm_nii_read(mfs.s.nii_fn);
    
    res = sqrt(f(median( (g(I, size(I,4)) - ...
        exp(cat(2, g(log(mfs.m(:,:,:,1)), 1), g(mfs.m(:,:,:,2:end),27)) * X')).^2, 2), 1));
    
    snr = mfs.m(:,:,:,1) ./ res;
    
    dps.mask_param = mio_mask_fill(mio_smooth_4d(snr, 1.5) > 50);
    
    f = fieldnames(dps);
    for c = 1:numel(f)
        try
            if (isstruct(dps.(f{c})))
                continue;
            elseif (size(dps.(f{c}), 1) == 3) % e.g. fa col
                dps.(f{c}) = dps.(f{c}) .* repmat(permute(dps.mask_param, [4 1 2 3]), [3 1 1 1]);
            elseif (size(dps.(f{c}), 1) == size(I,1)) % all other
                dps.(f{c}) = dps.(f{c}) .* dps.mask_param;
            end
        catch me
            disp(me.message);
        end
    end
end

% fill in dps fields
dps.nii_h = mfs.nii_h;
dps.mask  = mfs.mask;


if (~isempty(dps_fn))
    mdm_dps_save(dps, mfs.s, dps_fn, opt);
end





