function dps = dtd_cumulant_4d_fit2param(mfs_fn, dps_fn, opt)
% function dps = dtd_cumulant_2d_fit2param(mfs_fn, dps_fn, opt)

if (nargin < 2), mfs_fn = []; end
if (nargin < 3), opt    = []; end

opt = mdm_opt(opt);
mfs = mdm_mfs_load(mfs_fn);
sz  = msf_size(mfs.m(:,:,:,1), 3);

% reshape help functions
g = @(a,n) reshape(a, prod(sz(1:3)), n);
f = @(a,n) reshape(a, sz(1), sz(2), sz(3), n);
f2 = @(a)  reshape(a, sz(1:3));

% init dps
dps.nii_h = mfs.nii_h;
dps.mask  = mfs.mask;

% get data from input
% pull out the tensors (in um2/ms) and compute relevant metrics
dps.s0  = mfs.m(:,:,:,1);
% diffusion tensor
D_1x6  = g(mfs.m(:,:,:,2:7), 6) * 1e9;
% cumulant tensor
C_1x21  = g(mfs.m(:,:,:,8:28), 21) * 1e18;
% outer product of diffusion tensor
D2_1x21 = tm_1x6_to_1x21(D_1x6);
% fourth order tensor operators needed for the cumulant calculations
[E_bulk, E_shear, E_iso] = tm_1x21_iso;

% DTI paramters derived from first cumulant term (the diffusion tensor D)
dps.FA     = mio_min_max_cut( f(tm_fa(D_1x6), 1), [0 10]);
dps.MD     = mio_min_max_cut( f(tm_md(D_1x6), 1), [0 40]);
[L,U]      = tm_1x6_eigvals(D_1x6); % lambda and primary direction  u
dps.ad     = mio_min_max_cut( f(L(:,1), 1), [0 40]);
dps.rd     = mio_min_max_cut( f(mean(L(:,2:3),2), 1), [0 40]);
dps.u      = f(U,3);
dps.FA_col = permute(255 * abs(dps.u) .* repmat(dps.FA, [1 1 1 3]), [4 1 2 3]);

% DTD paramters derived from first and second cumulant term 
% ********* I.V_MD = I.V_MD1 - I.V_MD2 *************
dps.V_MD   = f2(tm_inner(C_1x21 , E_bulk));       %< C ,   E_bulk>
dps.V_iso  = f2(tm_inner(C_1x21 , E_iso));        %< C ,   E_iso>

dps.V_MD2  = f2(tm_inner(D2_1x21, E_bulk));       %< Dsol2, E_bulk>
dps.V_MD1  = dps.V_MD + dps.V_MD2;
dps.V_iso2 = f2(tm_inner(D2_1x21, E_iso));
dps.V_iso1 = dps.V_iso + dps.V_MD2;


% ***** I.V_shear = I.V_shear1 - I.V_shear2 *******
dps.V_shear  = f2(tm_inner(C_1x21, E_shear));     %< C ,    E_shear>
dps.V_shear2 = f2(tm_inner(D2_1x21, E_shear));    %< Dsol2, E_shear>
dps.V_shear1 = dps.V_shear + dps.V_shear2;        

% ********* Calculate normalized variance measures ************
reg = 0.1;   % % regularization parameter, *** need to better select this parameter
dps.C_MD    = dps.V_MD./max(dps.V_MD1,reg);
dps.C_mu    = 1.5*dps.V_shear1./max(dps.V_iso1,reg);
dps.C_M     = 1.5*dps.V_shear2./max(dps.V_iso2,reg);
dps.C_c     = dps.C_M./max(dps.C_mu,reg);

% clamp selected measures between 0 and 1
cl = @(x) min(max(x,0),1);
dps.C_mu  = cl(dps.C_mu);
dps.C_M   = cl(dps.C_M);
dps.C_c   = cl(dps.C_c);

if 0
% Kurtosis stuff if someone is curios 
dps.K_bulk  = 3*dps.V_MD./dps.V_MD2;           %< C , E_bulk>  / < Dsol2, E_bulk >
dps.K_shear = (6/5)*dps.V_shear./dps.V_MD2;    %< C , E_shear> / < Dsol2, E_bulk >
dps.MK      = dps.K_bulk + dps.K_shear;        %< C , E_tsym>  / < Dsol2, E_bulk >  %check formula
dps.K_mu    = (6/5)* dps.V_shear1./dps.V_MD1;  %      V_shear1 / < Dsol2, E_bulk >
% Explore using E_tsym for calcuating MK
E_tsym = E_bulk + (2/5)*E_shear;
end

if (~isempty(dps_fn))
    mdm_dps_save(dps, mfs.s, dps_fn, opt);
end


