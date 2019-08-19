function dps = dti_lls_4d_fit2param(mfs_fn, dps_fn, opt)
% function dps = dti_lls_4d_fit2param(mfs_fn, dps_fn, opt)
%
% this function should be more coordinated with dti_nls

if (nargin < 2), dps_fn = []; end
if (nargin < 3), opt = []; end

opt = mdm_opt(opt);
mfs = mdm_mfs_load(mfs_fn);
sz  = msf_size(mfs.m(:,:,:,1), 3);

g   = @(a,n) reshape(a, prod(sz(1:3)), n);
f   = @(a,n) reshape(a, sz(1), sz(2), sz(3), n);

% init dps
dps.nii_h = mfs.nii_h;
dps.mask  = mfs.mask;

% compute md, fa, and color fa
dps.s0 = mfs.m(:,:,:,1);

% pull out the tensors (in um2/ms) and compute relevant metrics
dt_1x6 = g(mfs.m(:,:,:,2:7), 6) * 1e9;

dps.fa  = mio_min_max_cut( f(tm_fa(dt_1x6), 1), [0 1]);
dps.md  = mio_min_max_cut( f(tm_md(dt_1x6), 1), [0 4]);

[L,U] = tm_1x6_eigvals(dt_1x6); % lambda and primary direction  u


dps.ad  = mio_min_max_cut( f(L(:,1), 1), [0 4]);
dps.rd  = mio_min_max_cut( f(mean(L(:,2:3),2), 1), [0 4]);
dps.u   = f(U, 3);

% ensure all parameters are real (imag values can arise if intensity is
% negative)
fn = {'s0', 'fa', 'md', 'ad', 'rd', 'u'};
for c = 1:numel(fn)
    dps.(fn{c}) = real(dps.(fn{c}));
end

dps.fa_col = permute(255 * abs(dps.u) .* repmat(dps.fa, [1 1 1 3]), [4 1 2 3]);


if (~isempty(dps_fn))
    mdm_dps_save(dps, mfs.s, dps_fn, opt);
end


