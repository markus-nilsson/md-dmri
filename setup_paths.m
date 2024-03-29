function setup_paths(do_restore_path)
% function setup_paths(do_restore_path)
%
% Restores the default paths and adds all relevant subdirs to the
% path. Run this when you start MATLAB to use the code.
%
% do_restore_path - optional, defaults to true

if (nargin < 1), do_restore_path = 1; end

clc;
disp('Welcome!');

% Test Matlab version number
switch(version('-release'))
    case {'2018a', '2018b', '2019a', '2020b'}
        1;
    otherwise
        disp('This MATLAB version is not supported by the framework');
        disp('It may or may not work as intended');        
end



if (do_restore_path)
    disp('Restoring default path');
    restoredefaultpath;
end

packages_dir = {...
    'mdm', ...
    'mio', ...
    'mio/elastix', ...
    'mio/fsl', ...
    'msf', ...
    'methods/dti_nls',...
    'methods/dti_lls',...
    'methods/dki_lls',...
    'methods/dki_pa',...
    'methods/quick_dti',...
    'methods/dtd',...
    'methods/ivim',...
    'methods/dtd_covariance',...
    'methods/dti_euler',...
    'methods/dtd_pa',...
    'methods/dtd_codivide',...
    'methods/dtd_ndi',...
    'methods/dtd_pake',...
    'methods/dtd_gamma',...
    'methods/dtd_saupe',...
    'methods/fexi11',...
    'methods/vasco16',...
    'methods/dtd_smr',...
    'methods/ning18', ...
    'tools/dist', ...
    'tools/gwf', ...
    'tools/tensor_maths', ...
    'tools/uvec', ...
    'tools/cfa', ...
    'tools/mplot', ...
    'tools/mgui', ...
    'tools/man', ...
    'tools/ut', ...
    };


t = fileparts(mfilename('fullpath'));

for c_package = 1:numel(packages_dir)
    addpath(fullfile(t, packages_dir{c_package}), '-end');
end

disp (char(10))
disp 'Done configuring paths for framework!'

