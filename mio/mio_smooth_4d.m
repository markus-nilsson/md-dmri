function I = mio_smooth_4d(I, filter_sigma, opt)
% function I = mio_smooth_4d(I, filter_sigma, opt)
%
% Gaussian smoothing with a width controlled by 'filter_sigma'

% init 
if (nargin < 2), filter_sigma = 0.5; end
if (nargin < 3), opt.present = 1; end
opt = mdm_opt(opt);

% Create filter
% filter_sigma = sigma .* (mean(h.pixdim(2:4)) ./ h.pixdim(2:4));
filter = my_fspecial('gaussian', [0 0 0] + round(max(filter_sigma) * 3)*2+1, ...
    filter_sigma, size(I(:,:,:,1)));

% Determine type of input
tmp = whos('I');
d_type = tmp.class;

% Smooth
for c = 1:size(I,4)
    I_tmp = double(I(:,:,:,c));
    I_tmp = imfilter(I_tmp, filter);
    I(:,:,:,c) = cast(I_tmp, d_type);
end

end

function filter = my_fspecial(filter_type, filter_size, filter_std, I_size)
% function filter = my_fspecial(filter_type, filter_size, filter_std, I_size)
%
% currently, this function only produce a 3d gaussian filter, but could be
% extended later

if (~strcmp(filter_type, 'gaussian'))
    error('function only defined for gaussian filters');
end

if (numel(I_size) == 2)
    filter = fspecial(filter_type, filter_size(1:2), median(filter_std));
    return;
end

if (numel(filter_size) ~= 3)
    error('only for 3d-filtering for now');
end

x      = zeros(filter_size);
y      = zeros(filter_size);
z      = zeros(filter_size);

for i = 1:filter_size(1)
    for j = 1:filter_size(2)
        for k = 1:filter_size(3)
            x(i,j,k) = i - (filter_size(1)+1)/2;
            y(i,j,k) = j - (filter_size(2)+1)/2;
            z(i,j,k) = k - (filter_size(3)+1)/2;
        end
    end
end

if (numel(filter_std) == 1)
    filter = exp( (- (x.^2 + y.^2 + z.^2) ) / (2 * filter_std^2));
elseif (numel(filter_std) == 3)
    filter = ...
        exp( (- (x.^2 ) ) / (2 * filter_std(1)^2)) .* ...
        exp( (- (y.^2 ) ) / (2 * filter_std(2)^2)) .* ...
        exp( (- (z.^2 ) ) / (2 * filter_std(3)^2));
    
else
    error('strange number of filter stds');
end

filter = filter / sum(filter(:));

end

