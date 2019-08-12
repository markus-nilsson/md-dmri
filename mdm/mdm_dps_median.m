function median_dps = mdm_dps_median(bs_dps)
% function median_dps = mdm_dps_median(bs_dps)
%

median_dps.nii_h = bs_dps{1}.nii_h;

sz = ones(1,3);
sz_temp = size(bs_dps{1}.s0);
sz(1:numel(sz_temp)) = sz_temp;

f = fieldnames(bs_dps{1});
for c = 1:numel(f)
    if (isstruct(bs_dps{1}.(f{c})))
        continue;
    elseif iscell(bs_dps{1}.(f{c}))

        for cbin = 1:numel(bs_dps{1}.(f{c}))
            fbin = fieldnames(bs_dps{1}.(f{c}){cbin});
            for cfbin = 1:numel(fbin)
                if (size(bs_dps{1}.(f{c}){cbin}.(fbin{cfbin}), 1) == sz(1)) 
                    ind_bs = find(~cellfun('isempty',bs_dps));
                    ptemp = zeros(sz(1),sz(2),sz(3),numel(ind_bs));
                    for nbs = 1:numel(ind_bs)
                        ptemp(:,:,:,nbs) = bs_dps{ind_bs(nbs)}.(f{c}){cbin}.(fbin{cfbin});
                    end
                    median_dps.(f{c}){cbin}.(fbin{cfbin}) = median(ptemp,4);
                end
            end                   
        end

    elseif (size(bs_dps{1}.(f{c}), 1) == sz(1)) 
        ind_bs = find(~cellfun('isempty',bs_dps));
        ptemp = zeros(sz(1),sz(2),sz(3),numel(ind_bs));
        for nbs = 1:numel(ind_bs)
            ptemp(:,:,:,nbs) = bs_dps{ind_bs(nbs)}.(f{c});
        end
        median_dps.(f{c}) = median(ptemp,4);
    end
end

