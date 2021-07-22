function dtd_example()
% function dtd_example()
%
% Recommended reading before you start
%
% Eriksson S, Lasic S, Nilsson M, Westin C-F, Topgaard D (2015) 
% NMR diffusion-encoding with axial symmetry and variable anisotropy: 
% Distinguishing between prolate and oblate microscopic diffusion tensors 
% with unknown orientation distribution. J Chem Phys 142(10):104201.
%
% Westin C-F, et al. (2016) Q-space trajectory imaging for 
% multidimensional diffusion MRI of the human brain. 
% NeuroImage 135:345?362.
%
% de Almeida Martins JP, Topgaard D (2016) Two-dimensional correlation of 
% isotropic and directional diffusion using NMR. Physical Review Letters. 
% doi:10.1103/PhysRevLett.116.087601.
%
% Play with this example to get a better understanding of the
% relationship between the b-tensor and the diffusion tensor distribution.


% generate three types of diffusion tensors
if (1)
    ad_1 = 2.9e-9;  % axial
    rd_1 = 0.5e-9;  % radial
    n_1  = 40;      % number of tensors
    
    ad_2 = 2.9e-9;
    rd_2 = 1.5e-9;
    n_2  = 50;
    
    d_iso = 3e-9;
    n_3   =20;
    
    % powder averaged data now (pa data)
    %
    % uvec_elstat generates a vector set distributed over the sphere to
    % minimize the electrostatic repulsion energy
    %
    % the code below yields n_i diffusion tensors with axial and radial
    % diffusivities of ad_i and rd_i, pointing in the uvec_elstat(n_i)
    % directions
    %
    dt_1 = tm_1x3_to_1x6(ad_1, rd_1, uvec_elstat(n_1));
    dt_2 = tm_1x3_to_1x6(ad_2, rd_2, uvec_elstat(n_2));
    dt_3 = tm_1x3_to_1x6(d_iso, d_iso, uvec_elstat(n_3));
    
    % size(dt) = (n_1 + n_2 + n_3) x 6, i.e., voigt notation of the dt
    dt = cat(1, dt_1, dt_2, dt_3); % this is our tensor distribution
end

% setup an experiment and generate signal data
if (1)
    
    % setup directions and b-values
    u = [1 0 0]; % one direction sufficient for pa-data
    b = linspace(eps, 3e9, 10)'; 

    b_delta = [0 0.7 1];
    
    % generate an xps for each b_delta, and merge them afterwards
    x = cell(1,numel(b_delta));
    for c = 1:numel(b_delta)
        
        b_radial = b * (1 - b_delta(c)) / 3;
        b_axial  = b - 2 * b_radial;
        
        x{c}.n = numel(b);
        x{c}.b = b;
        x{c}.bt = tm_1x3_to_1x6(b_axial, b_radial, u);
        x{c}.b_delta = zeros(size(b)) + b_delta(c);
        x{c}.b_eta   = zeros(size(b));
    end
    
    % merge all the sub-xps structures to make the xps represent all
    % measurements
    xps = mdm_xps_merge(x);
       

    % generate the signal, i.e., do synthetic measuerement
    S = mean(exp( - dt * xps.bt'), 1)';
    
    
    % plot the signal
    subplot(1,2,1); cla; hold off;
    l_str  = cell(1, max(xps.s_ind)); 
    h_plot = cell(1, max(xps.s_ind)); 
    
    for c = 1:max(xps.s_ind)
        ind = xps.s_ind == c;
        h_plot{c} = semilogy(xps.b(ind) * 1e-9, S(ind), 'o', 'linewidth', 2); hold on;
        l_str{c} = ['b_\Delta = ' num2str(mean(xps.b_delta(ind))) '^{ }'];
    end
    
    % fit a model and generate fitted signal
    c_model = 3;
    
    switch (c_model)
        
        case 1
            
            % Eriksson 2015
            opt = erf_opt;
            m = erf_1d_data2fit(S, xps, opt);
            S_fit = erf_1d_fit2data(m, xps);
        
        case 2
            
            % Lasic et al 2014
            opt = gamma_opt;
            m = gamma_1d_data2fit(S, xps, opt);
            S_fit = gamma_1d_fit2data(m, xps);
            
        case 3
            
            % de Almeida Martins et al 2016
            opt = dtd_pa_opt;
            m = dtd_pa_1d_data2fit(S, xps, opt);
            S_fit = dtd_pa_1d_fit2data(m, xps);
            
    end
    
    
    % plot fitted signal
    for c = 1:max(xps.s_ind)
        ind = xps.s_ind == c;
        h_plot{c} = semilogy(xps.b(ind) * 1e-9, S_fit(ind), '-', ...
            'linewidth', 2, 'color', get(h_plot{c}, 'color')); hold on;
    end
    
    
    box off;
    legend(l_str);
    legend boxoff;
    xlabel('b [um^2/ms]_{ }');
    ylabel('Signal');
    
    
end


% plot the tensors
if (1)
    
    subplot(1,2,2); cla;
    set(gcf,'color','white');
    
    mplot_tensors_in_voxel(dt);
   
end



