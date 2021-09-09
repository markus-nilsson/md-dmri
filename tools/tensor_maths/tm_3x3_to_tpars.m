function t = tm_3x3_to_tpars(t3x3)
% function t = tm_3x3_to_tpars(t3x3)
%
% Calculate derived tensor parameters.
%
% See definitions in
% Topgaard, In Diffusion NMR of Confined Systems: Fluid Transport in Porous Solids and Heterogeneous Materials;
% Valiullin, R., Ed.; Royal Society of Chemistry: Cambridge, UK, 2016, p 226.
% http://dx.doi.org/10.1039/9781782623779-00226


if (any(isnan(t3x3(:))) || any(isinf(t3x3(:))))
    t3x3 = zeros(3,3);
end

t.t1x6 = tm_3x3_to_1x6(t3x3);

[V,D] = eig(t3x3);
lambdas = diag(D);

% Trace and isotropic average
t.trace = sum(lambdas);
t.iso   = t.trace/3;

[~,ind] = sort(lambdas,'descend');

% Eigenvalue ordering convention as in Eq. (7.2) Topgaard 2016
t.lambda33    = lambdas(ind(1));                        
t.lambda22    = lambdas(ind(2));                       
t.lambda11    = lambdas(ind(3));  
t.lambda33vec = V(:,ind(1))';
t.lambda22vec = V(:,ind(2))';
t.lambda11vec = V(:,ind(3))';

% Linear, planar, and spherical components, see Eq. (7.5) Topgaard 2016
t.l = t.lambda33 - t.lambda22;
t.p = 2*(t.lambda22 - t.lambda11);
t.s = 3*t.lambda11;

% Eigenvalue ordering convention as in Eq. (7.10) Topgaard 2016
Dlambdas = abs(lambdas-t.iso);
[~,ind] = sort(Dlambdas,'descend');
t.lambdazz = lambdas(ind(1));
t.lambdaxx = lambdas(ind(2));                        
t.lambdayy = lambdas(ind(3));
t.lambdazzvec = V(:,ind(1))';
t.lambdaxxvec = V(:,ind(2))';
t.lambdayyvec = V(:,ind(3))';

% Normalized anisotropy and asymmetry , see Eq. (7.11) Topgaard 2016
t.delta = (t.lambdazz - (t.lambdayy+t.lambdaxx)/2)./(t.trace + eps);
t.eta = 3*(t.lambdayy - t.lambdaxx ) ./ (2*t.trace.*t.delta+eps);

% Variance of eigenvalues
t.vlambda = 1/3*((t.lambda33 - t.iso).^2 + (t.lambda22 - t.iso).^2 + (t.lambda11 - t.iso).^2);

% Fractional anisotropy, see Basser. J. Magn. Reson. B 111, 209 (1996).
t.fa = sqrt(1/2)*sqrt((t.lambda33-t.lambda22).^2+(t.lambda33-t.lambda11).^2+(t.lambda22-t.lambda11).^2)...
                    ./sqrt(t.lambda33.^2+t.lambda22.^2+t.lambda11.^2);
t.fa(isnan(t.fa)) = 0;

% Westin's macroscopic anisotropy measure, see Westin. Neuroimage 135, 345 (2016).
t.cm = t.vlambda./t.iso.^2;
t.cm(isnan(t.cm)) = 0;

% Westin's linear, planar, spherical measures, see Westin. Med. Image Anal. 6, 93 (2002).
t.cl = t.l./t.trace;
t.cl(isnan(t.cl)) = 0;
t.cp = t.p./t.trace;
t.cp(isnan(t.cp)) = 0;
t.cs = t.s./t.trace;
t.cs(isnan(t.cs)) = 0;


% Compute parallel and perpendicular components
% First determine whether it is prolate or oblate
if (t.cl > t.cp)
    t.para = t.lambda33;
    t.perp = (t.lambda11 + t.lambda22) / 2;
    t.norm = t.lambda33vec;
else
    t.para = t.lambda11;
    t.perp = (t.lambda22 + t.lambda33) / 2;
    t.norm = t.lambda11vec;
end
