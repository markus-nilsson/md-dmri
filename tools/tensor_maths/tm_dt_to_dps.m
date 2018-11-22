function dps = tm_dt_to_dps(dt_1x6, dps, f_reshape, reg)
% function dps = tm_dt_to_dps(dt, dps)
%
% dt - diffusion tensor(s) in 1x6 format
%
% optional
% dps       - display parameter structure
% f_reshape - function to reshape output parameters
%
% output:
% dps.(FA, MD, ad, rd, u, FA_col + V_MD2, V_iso2, V_shear2)

if (nargin < 2), dps = []; end
if (nargin < 3) || (isempty(f_reshape)), f_reshape = @(x,n) x; end
if (nargin < 4), reg = eps; end

% -------------------------------------------------------
% compute the second moments of the mean diffusion tensor
% -------------------------------------------------------

% fourth order tensor operators needed for the calculations
[E_bulk, E_shear, E_iso] = tm_1x21_iso();

dt2_1x21 = tm_1x6_to_1x21(dt_1x6);

% these makes sense first when used in tm_ct_to_dps
dps.V_MD2    = f_reshape(tm_inner(dt2_1x21, E_bulk), 1); % < Dsol2, E_bulk>
dps.V_iso2   = f_reshape(tm_inner(dt2_1x21, E_iso), 1);
dps.V_shear2 = f_reshape(tm_inner(dt2_1x21, E_shear), 1); %< Dsol2, E_shear>

% DTI parameters derived from the diffusion tensor 
dps.MD     = f_reshape(tm_md(dt_1x6), 1);
dps.FA     = f_reshape(tm_fa(max(dps.MD, reg), dps.V_shear2), 1);

% Compute parameters using eigenvalues L and primary direction U
[L,U]      = tm_1x6_eigvals(dt_1x6); 
dps.ad     = f_reshape(real(L(:,1)), 1);
dps.rd     = f_reshape(mean(real(L(:,2:3)),2), 1);
dps.u      = f_reshape(U,3);

% Only compute colour FA if output is a 3D volume
if (ndims(dps.FA) == 3)
    dps.FA_col = permute(255 * abs(dps.u) .* repmat(dps.FA, [1 1 1 3]), [4 1 2 3]);
end


