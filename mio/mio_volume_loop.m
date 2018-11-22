function p = mio_volume_loop(fun, I, M, opt, S)
% function p = mio_volume_loop(fun, I, M, opt, S)
%
% Applies the function fun to all voxels where M is positive
%
% In order to execute the loop in parallel, initiate parpool before
% executing this function. If number of workers > 1, volume loop will be
% executed in parallel
%
% fun - accepts one or two input arguments (signal vector + optionally
%          supplementary data)
%
% I   - 4D matrix
%
% M   - 3D mask
%
% opt - option structure
%
% S   - 4D supplementary data

tic;

if (nargin < 3), error('all inputs required'); end
if (nargin < 4), opt.present = 1; end
if (nargin < 5), S = []; end

opt = mio_opt(opt);

% Expand 4D volume to 2D so that n x m is samples x voxels
siz = size(I);
I   = reshape(I, prod(siz(1:3)), siz(4))';
M   = reshape(M, prod(siz(1:3)),      1)';

% Retain only non-masked-out voxels.
si  = find((M>0).*(~all(I==0,1))); % clear M here?
I   = double(I(:,si));

% Prepare supplementary information and function handles
if (~isempty(S))
    assert(all(siz==size(S)), 'S and I must be of equal size');
    S = reshape(S, prod(siz(1:3)), siz(4))';
    S = double(S(:,si));
    
    f_fun = @(x,y) fun(x,y);
    f_sup = @(K,i) K(:,i);
else
    f_fun = @(x,y) fun(x);
    f_sup = @(K,i) [];
end


% Find size of output by fitting to the first voxel
n_param   = numel(f_fun( I(:, 1), f_sup(S, 1) ));

% Assume local job (0 workers), but check if external worker(s) are requested.
n_workers = 0;

% Note 1: 0 workers runs the job locally, and 1 worker will run it in
% spmd. These may look identical, but if the local worker, and spmd worker
% are differnt physical processors there is a need for distinguishing them.
% Note 2: We use parallel computing on all available workers using SPMD.
% https://se.mathworks.com/help/distcomp/spmd.html
% SPMD was introduced in Matlab 2008b. The function is wrapped in an
% "else" statement to support users without parallel computing toolbox.
% It is possible that spmd(0) will run the job locally even for users that
% do not have parallel toolbox installed, hewver, this was not tested.

if (opt.mio.do_parfor)
    try % start parpool outside this function to have it run in parallel mode
        tmp = gcp('nocreate');
        n_workers = tmp.NumWorkers;
    catch
        if (opt.verbose)
            warning(['User requested parallel workers for mio_volume_loop but parpool ' ...
                'is not active! Continuing with job on a single local worker!'])
        end
    end
end


if (n_workers == 0)
    
    % Perform fitting on the local machine using one thread.
    out = mio_voxel_loop(f_fun, I, n_param, f_sup, S);
    
else
    
    % Perform fitting on parallel workers using SPMD.
    spmd
        I   = getLocalPart( codistributed(I) );
        S   = getLocalPart( codistributed(S) );
        out = mio_voxel_loop(f_fun, I, n_param, f_sup, S);
    end
    out = horzcat(out{:});
    
end

clear I;

% Revert mask subsampling
p = zeros(n_param, prod(siz(1:3)));
p(:,si) = out;

% Revert 2D to 4D transform so that we get "x, y, z, parameter" dimensions
p = reshape(p', siz(1), siz(2), siz(3), n_param);


if (opt.verbose)
    ttime = toc;
    disp(['Total fitting time = ' num2str(ttime/60, '%0.1f') ' min (' ...
        num2str(numel(si)/ttime, '%0.0f') ' voxels/s)'])
end

end


function out = mio_voxel_loop(h_fun, in, n_p_o, h_sup, in_sup)
% function out = mio_voxel_loop(h_fun, in, n_p_o, h_sup, in_sup)
% Basic function for looping over 1D voxels in 1D.

out = zeros(n_p_o, size(in,2));

for i = 1:size(in,2)
    out(:,i) = h_fun( in(:,i), h_sup(in_sup,i) );
end

end




