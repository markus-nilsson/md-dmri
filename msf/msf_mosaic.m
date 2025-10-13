function B = msf_mosaic(I,m,n, c_dim, c_vol)
% function B = msf_mosaic(I,m,n, c_dim)

if (nargin < 2), m = 3; end
if (nargin < 3), n = 3; end
if (nargin < 4), c_dim = 3; end
if (nargin < 5), c_vol = 1; end

if ((nargin < 5) || isempty(c_vol)) && (c_dim >= 4)
    dim_list = [NaN NaN NaN 3 2 1];
    c_vol = round(size(I,dim_list(c_dim)) / 2);
end

if (c_dim >= 4)
    if (m * n == size(I,4))
        k_list = 1:(m*n);
    else
        k_list = round(size(I,4) * linspace(0,1, m*n + 2));
        k_list = k_list(2:end);
    end
else
    if (m * n == size(I, c_dim))
        k_list = 1:(m*n);
    else
        k_list = round(size(I,c_dim) * linspace(0,1, m*n + 2));
        k_list = k_list(2:end);
    end
end




if (isempty(c_vol)), c_vol = 1; end

 


c_k = 1;
B = [];
for c_m = 1:m

    A = [];
    for c_n = 1:n

        switch (c_dim)
            case 1
                TMP = squeeze(I(k_list(c_k), :, :, c_vol));
            case 2
                TMP = squeeze(I(:, k_list(c_k), :, c_vol));
            case 3
                TMP = squeeze(I(:, :, k_list(c_k), c_vol));
            case 4
                TMP = squeeze(I(:, :, c_vol, k_list(c_k)));
            case 5
                TMP = squeeze(I(:, c_vol, :, k_list(c_k)));
            case 6
                TMP = squeeze(I(c_vol, :, :, k_list(c_k)));
        end

        A = cat(1, A, TMP);

        c_k = c_k + 1;

    end

    B = cat(2, B, A);
end

    

end