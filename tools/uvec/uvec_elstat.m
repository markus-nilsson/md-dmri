function [u, phi, theta] = uvec_elstat(n, version_str)
% function [u, phi,theta] = uvec_elstat(n)
%
% Loads electrostatically optimized angles

if (nargin < 2), version_str = 'filip'; end

u = []; phi = []; theta = [];

switch (version_str)
    
    case 'topgaard'
        
        assert( (n >= 10) & (n <= 1000), 'n outside allowed range');
        
        cwd = pwd;
        cd(fullfile(fileparts(mfilename('fullpath')), 'repulsion_angles'));
        load([num2str(n) '.mat']);
        cd(cwd);
        
        u = [sin(theta) .* cos(phi)  sin(theta) .* sin(phi) cos(theta)  ];
        
    case 'froeling' % from M.froeling@umcutrecht.nl's optimizer
        
        assert( (n >= 12) & (n <= 500), 'n outside allowed range');
        
        cwd = pwd;
        cd(fullfile(fileparts(mfilename('fullpath')), 'froejling'));
        load(sprintf('%03i', n));
        cd(cwd);
        
    case 'filip'
        
        assert( (n >= 1) & (n <= 79), 'n outside allowed range');
        
        fn = fullfile(fileparts(mfilename('fullpath')), 'Elstat_multiopt');
        
        txt = mdm_txt_read(sprintf('%s/Grad_dirs_multiopt_%i.txt', fn, n));
        
        u = cell2mat(cellfun(@(x) str2num(x)', txt, 'uniformoutput', 0))';
        
end

