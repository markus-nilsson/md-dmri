function [gwf_out, rf_out, dt_out] = gwf_interpolate(gwf, rf, dt, scale)
% function [gwf, rf, dt] = gwf_interpolate(gwf, rf, dt, scale)
%
% Interpolate the gwf -- currently nearest neighbour
%
% scale -- integer

if (isempty(rf)), rf = ones(size(gwf,1),1); end

gwf_check(gwf, rf, dt);

if (abs(mod(scale, 1)) < 0.001)
    
    scale = round(scale);
    
    gwf_out = zeros(size(gwf,1) * scale, 3);
    rf_out  = zeros(size(rf, 1) * scale, 1);
    
    for k = 1:scale
        gwf_out( ((1:size(gwf,1))-1) * scale + k, :) = gwf;
        rf_out ( ((1:size(gwf,1))-1) * scale + k, :) = rf;
    end
    
    dt_out = dt / scale;
    
else
    
    gwf_out = zeros(round(size(gwf,1) * scale), size(gwf,2));
    rf_out  = zeros(round(size(gwf,1) * scale), 1);
    
    for c = 1:size(gwf,2)
        gwf_out(:,c) = interp1(linspace(0,1,size(gwf,1)), gwf(:,c), linspace(0,1,size(gwf_out,1)));
    end

    rf_out(:,1) = interp1(linspace(0,1,size(rf,1)), rf, linspace(0,1,size(rf_out,1)));

    dt_out = dt / scale;
    
end

