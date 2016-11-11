function dps = gamma_4d_fit2param(mfs_fn, dps_fn, opt)
% function dps = gamma_4d_fit2param(mfs_fn, dps_fn, opt)

if (nargin < 2), dps_fn = []; end
if (nargin < 3), opt = []; end

opt = mdm_opt(opt);
dps = mdm_mfs_load(mfs_fn);

% create parameter maps and save them
dps.s0 = dps.m(:,:,:,1);
dps.iso = dps.m(:,:,:,2);
dps.mu2iso = dps.m(:,:,:,3);
dps.mu2aniso = dps.m(:,:,:,4);

dps.vlambda = 5/2*dps.mu2aniso;
dps.vlambda(isnan(dps.vlambda)) = 0;
dps.ufa = sqrt(3/2)*sqrt(1./(dps.iso.^2./dps.vlambda+1));
dps.ufa(isnan(dps.ufa)) = 0;
dps.ciso = dps.mu2iso./dps.iso.^2;
dps.ciso(isnan(dps.ciso)) = 0;
dps.cmu = dps.ufa.^2;

% Store signal baseline where possible
if size(dps.m, 4) >4
  for i = 5:size(dps.m,4)
    dps.(['s' num2str(i-4)]) = dps.m(:,:,:,i);
  end
end

% Parameters according to style in Szczepankiewiz et al. 2015 (Neuroimage)
dps.MD = dps.m(:,:,:,2)*1e9;     % Unit is  µm^2/ms
dps.Vi = dps.m(:,:,:,3)*1e9*1e9; % Unit is (µm^2/ms)^2
dps.Va = dps.m(:,:,:,4)*1e9*1e9; % Unit is (µm^2/ms)^2
dps.Vt = dps.Vi + dps.Va;        % Unit is (µm^2/ms)^2

dps.NVi = dps.Vi ./ dps.MD.^2; % Unit is 1
dps.NVa = dps.Va ./ dps.MD.^2;
dps.NVt = dps.Vt ./ dps.MD.^2;

% Parameters according to style in Szczepankiewiz et al. 2016 (Neuroimage)
% Parameters scaled according to "mean kurtosis" by Jensen 2015
dps.MKi = 3 * dps.Vi ./ dps.MD.^2; % Unit is 1
dps.MKa = 3 * dps.Va ./ dps.MD.^2;
dps.MKt = 3 * dps.Vt ./ dps.MD.^2;

dps.Vl = 5/2 * dps.Va; % Unit is (µm^2/ms)^2

dps.ufa_old = dps.ufa; % Old definition, replaced by definition in Westin et al. 2016, Neuroimage
dps.ufa     = sqrt(3/2) * sqrt( dps.Vl ./ (dps.Vl + dps.Vi + dps.MD.^2) );


if (~isempty(dps_fn)), mdm_dps_save(dps, dps.s, dps_fn, opt); end
