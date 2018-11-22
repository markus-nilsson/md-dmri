function fn = ut_cfa(c_ut)
% function fn = ut_cfa(c_ut)
%
% if c_ut is not supplied, the function returns the number of unit tests
% n_ut = number of unit tests

fn   = 'ut_cfa';
n_ut = 4;

if (nargin < 1), fn = n_ut; return; end

switch c_ut
    
    case 1 % Test the core bias funnction for waveform that renders no error.
        gwf = [
            0 1 1 1 1 1 0 0 0 1 1 1 1 1 0;
            0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
            0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
            ]'*.08;
        
        rf  = [1 1 1 1 1 1 0 0 0 -1 -1 -1 -1 -1 -1]';
        
        dt = 5e-3;
        
        ips = get_ips();
        
        c = cfa_maxwell_bias(gwf, rf, dt, ips);
        
        if ~all(c)
            error('%s test %i, error calc returns unexpected values!', fn, c_ut);
        end
        
        
    case 2 % Test the core bias funnction for waveform that renders no error.
        gwf = [
            0 1 1 0 -1 -1 0 0 0 0 0 0  0  0 0;
            0 0 0 0  0  0 0 0 0 0 0 0  0  0 0;
            0 0 0 0  0  0 0 0 0 1 1 0 -1 -1 0;
            ]'*.08;
        
        rf  = [1 1 1 1 1 1 0 0 0 -1 -1 -1 -1 -1 -1]';
        
        dt = 5e-3;
        
        ips = get_ips();
        
        c = cfa_maxwell_bias(gwf, rf, dt, ips);
        
        if min(c) < 0.67471267*(1-1e-5) || min(c) > 0.67471267*(1+1e-5)
            error('%s test %i, error calc returns unexpected values!', fn, c_ut);
        end
        
        
    case 3 % Check that cfa_apply_R_to_fov works
        ips.o = rand(3);
        
        R = [0 1 0; 1 0 0; 0 0 1];
        
        r = ips.o * R;
        
        ips = cfa_apply_R_to_fov(ips, R);
        
        if ~all(r(:) == ips.o(:))
            error('%s test %i, rotation of ips.o returns unexpected values!', fn, c_ut);
        end
    
        
    case 4 % Check that cfa_check_ips works
        
        ips = get_ips();
        cfa_check_ips(ips);
        
        
    otherwise
        error(['No such test is defined! (Requested test: ' num2str(c_ut) ')']);
        
end

end



function ips = get_ips()
% Create an example ips

ips.B0  = 3;                            % main magnetic field [T]
ips.gm  = msf_const_gamma;              % gyromagnetic constant [rad/T]

v_f     = [1 0 0];                      % vector along freq. enc direction
v_p     = [0 1 0];                      % vector along phase enc direction
v_s     = [0 0 1];                      % vector along slice normal direction

ips.o   = [v_f; v_p; v_s];              % orientation matrix

ips.fov = [.2 .3 .1];                   % fov size along FPS [m]
ips.res = [2 2 4] * 1e-3;               % spatial resolution in FPS [m]
ips.ipa = 2;                            % in-plane acceleration factor [1]
ips.ecs = .65e-3;                       % echo spacing [s]

ips.kpv = ips.ipa/ips.fov(2)/ips.ecs;   % k-phase velocity [1/(s.m)]

[X, Y, Z] = cfa_fov_to_xyz(ips.fov, ips.res);
ips.r_xyz = [X(:) Y(:) Z(:)];           % position of all voxel centers [m]


% Not really imaging parameter -- but required for CFA
ips.T2s = 40e-3;                        % T2-star time of tissue [s]

end