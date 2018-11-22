% Init
rng(1);

% Generate a diffusion tensor distribution
ad_1 = 3.0e-9; % axial diffusivity
rd_1 = 0.3e-9; % radial diffusivity
n_1  = [1 0 0]; % direction

ad_2 = 2.0e-9;
rd_2 = 1.0e-9;
n_2 = [0 1 0];

ad_3 = 0.1e-9;
rd_3 = ad_3;
n_3 = [1 0 0];

dt = cat(1, ...
    tm_1x3_to_1x6(ad_1, rd_1, n_1), ...
    tm_1x3_to_1x6(ad_2, rd_2, n_2), ...
    tm_1x3_to_1x6(ad_3, rd_3, n_3));

% Prepare the measurement
b_max = 10e9;
b = linspace(0,1, 8).^2 * b_max * 0.99 + 0.01 * b_max;

b_delta = [1 0 -0.5]; % tensor shapes

xps = {};
for c_delta = 1:numel(b_delta)
    for c_b = 1:numel(b)
        n_rand = randi(9) + 20;
        
        n = uvec_elstat(n_rand);
        
        ab = b(c_b) * (b_delta(c_delta) + 0.5) / 1.5;
        rb = (b(c_b) - ab) / 2;
        
        bt = tm_1x3_to_1x6(ab, rb, n); % b-tensor
        
        % prepare eXperiment Parameter Structure
        xps{end+1} = mdm_xps_from_bt(bt); 
        
    end
end

% Merge and scramble xps for prettier plots
xps = mdm_xps_merge(xps);
xps = rmfield(xps, 's_ind');

xps_cell = cell(1,xps.n);
for c = 1:xps.n
    xps_cell{c} = mdm_xps_subsample(xps, (1:xps.n) == c);
end
xps = mdm_xps_merge(xps_cell(randperm(xps.n)));


% Generate data
S = mean(exp(-xps.bt * dt'), 2) + randn(xps.n,1) * 0.001;

% Plot
clf; 
axes('position', [0.15 0.17 0.8 0.75]);
opt.mplot.fs = 14;

dmin = 10^(-10.5);
dmax = 10^(-8.5);

c_case = 3;
switch (c_case)
    case 1 % Underlying DTD
        mplot_dtd(dt, [], dmin, dmax, gca, opt);
    
    case 2 % Signal and fit
        opt = dtd_opt();
        mplot_signal_and_fit(S, xps, @dtd_1d_data2fit, @dtd_1d_fit2data, gca, opt);
        
    case 3 % Fitted distribution
        m = dtd_1d_data2fit(S, xps, dtd_opt);
        [dtd_1x6,w] = dtd_dist2nx6w(dtd_m2dtd(m));
        mplot_dtd(dtd_1x6, w, dmin, dmax, gca, opt);
end



