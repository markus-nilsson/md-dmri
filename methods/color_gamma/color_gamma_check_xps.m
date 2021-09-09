function xps = color_gamma_check_xps(xps)
% function color_gamma_check_xps(xps)
% 
% checks that all required fields are found in the xps

mdm_xps_check(xps);

required_fields = {...
    'bt'};

for c = 1:numel(required_fields)
    if (~isfield(xps, required_fields{c}))
        error('xps.%s not found', required_fields{c});
    end
end

if any(~isfield(xps, {'b0_logical';'b_unique';'b_ind';'bd_unique';'bd_ind';'bu_unique';'bu_ind'}))
    xps.b0_logical = xps.b==0;
    [xps.b_unique,~,xps.b_ind] = uniquetol(xps.b,0.01);
    [xps.bd_unique,~,xps.bd_ind] = uniquetol(xps.b_delta,0.01);
    [xps.bu_unique,~,xps.bu_ind] = uniquetol(xps.u,0.01,'byrows', true);
    [xps.bdu_unique,~,xps.bdu_ind] = uniquetol([xps.b_delta xps.u],0.01,'byrows', true);
    [xps.sbdu_unique,~,xps.sbdu_ind] = uniquetol([xps.s_ind xps.b_delta xps.u],0.01,'byrows', true);
    xps.Nb = numel(xps.b_unique);
    xps.Nbd = numel(xps.bd_unique);
    xps.Nbu = size(xps.bu_unique,1);
    xps.Nbdu = size(xps.bdu_unique,1);
    xps.Nsbdu = size(xps.sbdu_unique,1);
end

