function M = mio_mask_radial(I, opt)
% function M = mio_mask_mic(I, opt)

if (nargin < 3), opt.present = 1; end
opt.mask.present = 1;
opt.mask = msf_ensure_field(opt.mask, 'b0_ind', 1);


n_spoke = 2 * size(I,1);

% define the radiality
t = linspace(0,2*pi,n_spoke);
t = [t(1) - (t(2)-t(1)) t];

mx = size(I,2) / 2;
my = size(I,1) / 2;
n  = min(size(I,1), size(I,2));
nx = 0.98*n/2 - 1;
ny = nx;
m0 = repmat([mx; my], 1, n)';

OM = zeros(size(I(:,:,:,opt.mask.b0_ind)));
for k = 1:size(I,3) % traverse in third dimension for now
    try
        J = I(:,:,k, opt.mask.b0_ind);
        
        % compute radial spokes
        for c = 1:numel(t)
            x(:,c) = linspace(1,0,n)' * cos(t(c)) * nx + mx;
            y(:,c) = linspace(1,0,n)' * sin(t(c)) * ny + mx;
            
            try
                ind = sub2ind(size(J), round(x(:,c)), round(y(:,c)));
                Y(:,c) = J(ind);
            catch me
                error('stop');
            end
        end
        
        % detect borders (positive going from background to object)
        nf = 3;
        flt = ones(nf,nf)/nf^2;
        M = diff(convn(Y,flt,'same'),1);
        M = M .* (M > 0);
        M = convn(M, flt, 'same');
        M2 = (M > quantile(M(:), 0.7));
        
        nc = round(0.05 * n);
        
        M2 = convn(M2, ones(nc,1)/nc, 'same') > 0.5;
        M2 = convn(M2, ones(nc,1)/nc, 'same') > 0.5;
        M2 = convn(M2, ones(1,3), 'same') > 0;
        
        % remove the extra spoke used for correct filtration
        M  = M(:,2:end-1);
        M2 = M2(:,2:end-1);
        
        % detect the border
        clear tx ty Mind;
        for c = 1:size(M,2)
            tmp = find(M2(:,c), 1, 'first');
            
            try
                tmp = tmp + (0:20);
                [~,tmp2] = max(M(tmp,c));
                tmp = tmp(tmp2);
            catch me
                tmp = [];
            end
            
            if (isempty(tmp))
                Mind(c) = NaN;
            else
                Mind(c) = tmp + 5;
            end
        end
        
        % filter away bad indices
        ind = (1:numel(Mind)) + numel(Mind);
        Mind = cat(2, Mind, Mind, Mind)';
        
        f = @(x) x(ind);
        
        ck = round(0.1 * numel(t));
        
        smind   = smooth(Mind, ck);
        madind = mad( f(Mind - smind));
        
        fmind = zeros(size(Mind));
        for c = ck:(numel(Mind) - ck)
            
            tmpx = Mind( c + (-(ck-1):(ck-1)) );
            tmpsx = smind( c + (-(ck-1):(ck-1)) );
            
            tmpind = abs(tmpx - tmpsx) < 3 * madind;
            
            tmp = linspace(-1,1,numel(tmpx))';
            
            try
                p = polyfit(tmp(tmpind), tmpx(tmpind), 2);
                fmind(c) = polyval(p, 0);
            catch me
                1;
                fmind(c) = 0;
            end
            
        end
        
        Mind = Mind(ind);
        fmind = fmind(ind);
        
        
        % translate index to position
        clear fx fy;
        for c = 1:numel(Mind)
            fx(c) = x(round(fmind(c)), c);
            fy(c) = y(round(fmind(c)), c);
        end
        
        ind = sub2ind(size(J), round(fx), round(fy));
        LM = zeros(size(J));
        LM(ind) = 1;
        LM = mio_mask_fill(convn(LM, ones(5,5)/25, 'same') > 0.0);
        
        OM(:,:,k) = LM;
        
    catch me
        disp(me.message);
    end
    
end

M = OM;
