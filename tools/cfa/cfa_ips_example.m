function ips = cfa_ips_example()
% function ips = cfa_ips_example()

ips.B0 = 3;                             % main magnetic field [T]
ips.gm = msf_const_gamma;               % gyromagnetic constant [rad/T]

v_f = [1 0 0];                          % vector along freq. enc direction
v_p = [0 1 0];                          % vector along phase enc direction
v_s = [0 0 1];                          % vector along slice normal direction

ips.o   = [v_f; v_p; v_s];              % orientation matrix

ips.fov = [.22 .24 .26];                % fov size along FPS [m]
ips.res = [4 4 4] * 1e-3;               % spatial resolution in FPS [m] 
ips.ipa = 2;                            % in-plane acceleration factor [1]
ips.ecs = .65e-3;                       % echo spacing [s]

% Not really imaging parameter -- but required for CFA
ips.T2s = 40e-3;                        % T2-star time of tissue [s]

% derived parameters
ips = cfa_ips_update_derived_pars(ips);

cfa_check_ips(ips);


