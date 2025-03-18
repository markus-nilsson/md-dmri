function c_slice = mgui_misc_roi_centre(I_roi)
% function c_slice = mgui_misc_roi_centre(I_roi)
% 
% decice which slice to start focusing on

c_slice = zeros(1,3);

c_method = 2;
switch (c_method)

    case 1 % old standard method

        for c_dim = 1:3

            I_tmp = I_roi;
            for c_dim2 = find(1:3 ~= c_dim)
                I_tmp = sum(I_tmp, c_dim2);
            end
            I_tmp = squeeze(I_tmp(:))';
            com = sum(I_tmp .* (1:numel(I_tmp))) ./ sum(I_tmp);

            if (round(com) > 0)
                c_slice(c_dim) = round(com);
            else
                c_slice(c_dim) = round(numel(I_tmp) / 2);
            end
        end

    case 2

        for c_dim = 1:3

            I_tmp = I_roi;
            for c_dim2 = find(1:3 ~= c_dim)
                I_tmp = sum(I_tmp, c_dim2);
            end
            I_tmp = squeeze(I_tmp(:))';

            [~,c_slice(c_dim)] = max(I_tmp);

        end


end

