function s = dtd_gamma_1d_fit2data(m, xps)
% function s = dtd_gamma_1d_fit2data(m, xps)

% Convert to readable parameters
s0        = m(1);         % Signal at no diff encoding (baseline signal)
d_iso     = m(2);         % Average isotropic diffusivity (mean diffusivity)
mu2_iso   = m(3);         % Isotropic variance
mu2_aniso = m(4);         % Anisotropic variance

rs        = [1 m(5:end)]; % Relative signal (Series 1, 2, 3, ...)

% Signal baseline coefficient that adjusts for variable baseline signal
% across multiple series (xps.s_ind).
if (numel(rs) > 1)
    sw = s0 * sum(  mtimes(  ones(size(xps.b)), rs       ) .* ...
                 (  bsxfun(@eq, xps.s_ind, 1:numel(rs))  )  , 2);
else
    sw = s0;
end
                   
% Total diffusional variance (mu2) is the weighted sum of the isotropic 
% (mu2_iso) and anisotorpic (mu2_aniso) components.
mu2 = mu2_iso + mu2_aniso.*xps.b_delta.^2.*(xps.b_eta.^2+3)/3;

% Signal equation based on the Laplace transform of the gamma distribution.
s = sw.*(1 + xps.b.*mu2./d_iso).^(-1*(d_iso.^2./mu2));

% Force signal to be real. This is necessary when allowing negative
% variances.
s = real(s);

