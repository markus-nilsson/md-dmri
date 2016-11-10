function paths = mdm_paths(tmp, prefix, suffix)
% function paths = mdm_paths(tmp, prefix, suffix)
%
% paths will get the required fields:
% paths.(mfs_fn/dps_fn/nii_path)
%
% if tmp is a string, these will be created assuming tmp is a path to the
% folder where the mfs, dps and nii:s are going to be stored
%
% if tmp is a struct, we verify that these fields are present

if (nargin < 2), prefix = []; end
if (nargin < 3), suffix = []; end

if (ischar(tmp))
    paths.pa_fn  = fullfile(tmp, [prefix 'pa' suffix '.nii.gz']);
    paths.mfs_fn = fullfile(tmp, [prefix 'mfs' suffix '.mat']);
    paths.dps_fn = fullfile(tmp, [prefix 'dps' suffix '.mat']);
    paths.nii_path = fullfile(tmp);
elseif (isstruct(tmp))
    paths = tmp;
else
    error('expected input to be either string or structure');
end

assert(isfield(paths, 'mfs_fn'), 'mfs_fn field not found in paths');
assert(isfield(paths, 'dps_fn'), 'dps_fn field not found in paths');
assert(isfield(paths, 'nii_path'), 'nii_path field not found in paths');


