clear

% Here are some examples of asymmetric diffusion encoding in a spin-echo
% sequence. See the example cases to experiment with some common issues.

example_nr = 9;

switch example_nr
    case 1
        % The stejskal-tanner experiment is symmetric and will never
        % produce any residual zeroth moment due to  maxwell terms, 
        % regardless of rotations of gwf and fov.
        wf_type    = 1; % ST
        find_worst = 1; % none of the modes have any effect
        
    case 2
        % If we run a DDE with orthogonal gradients in the xy-plane, no
        % errors will appear!
        wf_type    = 2; % DDE in x and y
        find_worst = 2; % rotating the fov, but it has no effect
        
    case 3
        % If we use the DDE in x and y, but allow it to rotate, there will
        % be a gross signal error away from the iso center.
        wf_type    = 2; % DDE in x and y
        find_worst = 1; % worst rotation of gradients
        
    case 4
        % If we start with DDE in the xz-plane, there will always be an
        % error, even if the gradient and the fov are not rotated.
        wf_type    = 3; % DDE in x and z
        find_worst = 0; % no rotation
        
    case 5
        % If we start with DDE in the xz-plane, there will always be an
        % error, and it can get even worse if we search for the worst fov
        % or gvf rotation.
        wf_type    = 3; % DDE in x and z
        find_worst = 2; % find worst FOV rotation
        
    case 6
        % If we design LTE so that it uses all available encoding time in
        % an assymetric spin echo, this will also be unbalanced by Maxwell
        % terms.
        wf_type = 4;
        find_worst = 0;
        
    case 7
        % Bipolar double spin-echo
        wf_type = 5;
        find_worst = 0;
        
    case 8
        % Bipolar double spin-echo
        wf_type = 6;
        find_worst = 0;
        
    case 9
        % Quadratic nulling in 1D ensures that there are no concomitant
        % effects.
        wf_type = 9;
        find_worst = 2;
end


% Fetch imaging parameter structure (ips), and gradient waveform (gwf)
ips = cfa_ips_example();
[gwf, rf, dt] = cfa_gwf_example(wf_type); % 1 is ST-SDE; 2 is ortho DDE in x & y; 3 is ortho DDE in x & z


% Rotations of the FOV and the gwf are imortant and we can fing the worst
% rotation by an fminsearch.
switch find_worst
    case 0 % do nothing
        
    case 1 % Find worst rotation of gwf
        R = cfa_find_worst_gwf_rot(gwf, rf, dt, ips, 1);
        gwf = gwf * R;
        
    case 2 % Find worst rotation of FOV
        R = cfa_find_worst_fov_rot(gwf, rf, dt, ips, 1);
        ips = cfa_apply_R_to_fov(ips, R);
        
    case 3 % random rotation of waveform
        R = wf_create_random_rot_mat();
        gwf = gwf * R;
        
end


%% PLOT RELATIVE SIGNAL
figure(1)
gwf_plot_all(gwf, rf, dt);

figure(2)
cfa_plot_all(gwf, rf, dt, ips, 0);

% figure(3) % Online correction can fix the maxwell terms close to a single position per shot.
% pos = [0 0 .1];
% gwfc = cfa_gwf_to_corr_gwf(gwf, pos, ips.B0, 0);
% ips2 = ips; ips2.r_xyz = pos;
% cs = cfa_maxwell_bias(gwfc, rf, dt, ips2, 1);
% h = cfa_plot_all(gwfc, rf, dt, ips, 0);
% title(h(1), {['AF @ ' num2str(pos, '  %0.2f')]; [' = ' num2str(cs, '%0.2f')]})

