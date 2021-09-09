function dps_fn = dtd_saupe_4d_fit2param(mfs_fns, dps_fn, opt)
% function fn = dtd_saupe_4d_fit2param(mfs_fn, o_path, opt)
%
% Saupe order tensor imaging
% Combination of DTI, gamma, and erf
% Topgaard, Phys. Chem. Chem. Phys. (2016).
% http://dx.doi.org/10.1039/c5cp07251d

if (nargin < 2), dos_fn = []; end
if (nargin < 3), opt = []; end

opt = mdm_opt(opt);

dps_dti   = dti_euler_4d_fit2param(mfs_fns{1});
dps_gamma = dtd_gamma_4d_fit2param(mfs_fns{2});
dps_pake   = dtd_pake_4d_fit2param(mfs_fns{3});
dps       = dps_dti;

sz = size(dps.m);

% create parameter maps and save them
kronecker = permute(repmat([1 1 1 0 0 0]',[1 sz(3) sz(2) sz(1)]),[4 3 2 1]);
dps.s1x6 = (dps_dti.t1x6./repmat(dps_dti.iso,[1 1 1 6]) - kronecker)./repmat(dps_pake.delta,[1 1 1 6])/2;
dps.s1x6prim = (2*dps.s1x6 + kronecker)/3;
dps.s1x6(isnan(dps.s1x6)) = 0;
dps.s1x6prim(isnan(dps.s1x6prim)) = 0;

dps.slambdaxx = (dps_dti.lambdaxx./dps_pake.iso - 1)./dps_pake.delta/2;
dps.slambdaxx(isnan(dps.slambdaxx)) = 0;
dps.slambdayy = (dps_dti.lambdayy./dps_pake.iso - 1)./dps_pake.delta/2;
dps.slambdayy(isnan(dps.slambdayy)) = 0;
dps.slambdazz = (dps_dti.lambdazz./dps_pake.iso - 1)./dps_pake.delta/2;
dps.slambdazz(isnan(dps.slambdazz)) = 0;

dps.slambdaxxprim = (2*dps.slambdaxx + 1)/3;
dps.slambdayyprim = (2*dps.slambdayy + 1)/3;
dps.slambdazzprim = (2*dps.slambdazz + 1)/3;

dps.slambdas = zeros([sz(1) sz(2) sz(3) 3]);
dps.slambdas(:,:,:,1) = dps.slambdaxxprim;
dps.slambdas(:,:,:,2) = dps.slambdayyprim;
dps.slambdas(:,:,:,3) = dps.slambdazzprim;
dps.slambda11prim = min(dps.slambdas,[],4);
dps.slambda33prim = max(dps.slambdas,[],4);
dps = rmfield(dps,'slambdas');

dps.op = abs(dps.slambdazz);
dps.ufa       = dps_pake.ufa;

if (~isempty(dps_fn)) mdm_dps_save(dps, dps.s, dps_fn, opt); end



