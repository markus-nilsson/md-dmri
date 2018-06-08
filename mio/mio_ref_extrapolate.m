function I_ref = mio_ref_extrapolate(I, xps_source, xps_target, M, ind, opt)
% function I_ref = mio_ref_extrapolate(I, xps_source, xps_target, M, ind)
%
% Extrapolate references according to Nilsson et al, 2015, Plos One 
% doi:10.1371/journal.pone.0141825

assert(isfield(xps_source, 'n'), 'xps_source.n required field');
assert(isfield(xps_source, 'bt'), 'xps_source.bt of size n x 6 required');

if (nargin < 3), xps_target = xps_source; end
if (nargin < 4), M = []; end
if (nargin < 5), ind = (1:xps_source.n) > 0; end
if (nargin < 6), opt = []; end

opt = mio_opt(opt);

% Get sizes
sz_source = [size(I,1) size(I,2) size(I,3) size(I,4)];
sz_target = sz_source; 
sz_target(4) = xps_target.n;


% Log-transform data and build regressor
I = reshape(I, [prod(sz_source(1:3)) sz_source(4)]); 
I = log(double(I));
I(isinf(I)) = NaN;

x = [-xps_source.bt' * 1e-9; ones(1, xps_source.n)];

% Check for appropriate subspace size
if (rank(x(:,ind) * x(:,ind)', 1e-10) < 7)
    if (opt.mio.ref_extrapolate.do_subspace_fit)
        e = [...
            1 0 0 0 0 0 0;
            0 1 0 0 0 0 0;
            0 0 1 0 0 0 0;
            0 0 0 0 0 0 1];
    else
        error('Not enough gradient directions in low b-value shells for this, try enabling opt.mio.ref_extrapolate.do_subspace_fit');
    end
else
    e = eye(7);
end

% Solve the regression problem
% ----------------------------
% Y = B * X
% n_pix x n_vol = n_pix x 7  7 x n_vol
%
% Y * X' * inv(X * X')
DT = (I(:,ind) / (e * x(:,ind))) * e;


% Amend nan tensors within mask (need to supply mask in order to avoid 
% looong calculation times
if (~isempty(M))
    
    ind_nan = find(M(:) & isnan(DT(:,1)));
    
    DT2 = DT;
    for c_ind = 1:numel(ind_nan)
        
        [i,j,k] = ind2sub(sz_source(1:3), ind_nan(c_ind));
        
        D_tmp = zeros(1,size(DT,2));
        c_tmp = 0;
        
        for di = -1:1
            for dj = -1:1
                for dk = -1:1
                    try
                        ind_tmp = sub2ind(sz_source(1:3), i+di,j+dj,k+dk);
                        if (any(isnan(DT(ind_tmp,:)))), continue; end
                        D_tmp = D_tmp + DT(ind_tmp,:);
                        c_tmp = c_tmp + 1;
                    catch me
                        % no worries
                    end
                end
            end
        end
        DT2(ind_nan(c_ind),:) = D_tmp / c_tmp;
    end
    DT = DT2;
    
end

DT = real(DT);


% Calculate MD
MD = mean(DT(:,1:3), 2);

% Transfer some MD to an isotropic tensor
D_tissue = 0.75; % Bennett2003 average
D_CSF = 2.1; % lower than true value due to PVE in estimation
f_CSF = (MD - D_tissue) / (D_CSF - D_tissue);
f_CSF(f_CSF < 0) = 0;
f_CSF(f_CSF > 0.99) = 0.99;


% Adjusted diffusion tensor, DT2, and CSF-tensor: DT_CSF
DT_2 = DT;
DT_2(:, 1:3) = (DT_2(:, 1:3) - D_CSF * repmat(f_CSF, [1 3])) ./ (1 + eps - repmat(f_CSF, [1 3]));
MD_2 = mean(DT_2(:,1:3),2);
DT_2(MD_2 > D_tissue, 1:3) = D_tissue;
DT_2(MD_2 > D_tissue, 4:6) = 0;
MD_2 = mean(DT_2(:,1:3),2);


% Make an adjustment to low MD voxels
DT_3 = DT_2;
D_min = 0.3;
ind_low = MD_2 < D_min;
DT_3(ind_low,1:3) = DT(ind_low,1:3) + (D_min - repmat(MD_2(ind_low), [1 3])); % just make it fatter in all directions


% Second, make adjusted ref
% Calculate D in every voxel
% Adjust it to be in the range 0.3-1.2, seems reasonable for tissue
% Use the stretched exponendial model with alpha = 0.75 for all voxels
D_min = 0.3;
D_max = 1.2;
alpha = 0.8; % Bennet 2003, stretched exponential

b_target = repmat(xps_target.b', [size(DT_3,1) 1]);
D = DT_3(:,1:6) * (xps_target.bt + eps)' ./ (b_target + eps);

D(D < D_min) = D_min;
D(D > D_max) = D_max;

% Restore to SI units
D = D * 1e-9; 
D_CSF = 3e-9;

% Calculate S0
S0 = repmat(exp(DT_3(:,7)), [1 xps_target.n]);

% Calculate output
I_ref = ...
    repmat(1 - f_CSF, [1 xps_target.n]) .* exp(-(D .* b_target).^(alpha)) + ...
    repmat(0 + f_CSF, [1 xps_target.n]) .* exp(-b_target * D_CSF);

I_ref = reshape(S0 .* I_ref, sz_target);

I_ref(isnan(I_ref(:))) = 0;





