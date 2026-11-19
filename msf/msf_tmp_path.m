function tmp_path = msf_tmp_path(do_mkdir)
% function tmp_path = msf_tmp_path(do_mkdir)
%
% Obtains a temporary path with a random name

if (nargin < 1), do_mkdir = 1; end

% Create a unique temporary directory name to make the code thread safe.
% tmp_path = fullfile(tempdir, 'mdm', char(java.util.UUID.randomUUID)); % may result in permission denied when mkdir
tmp_path = fullfile(tempdir, ['mdm_' char(java.util.UUID.randomUUID)]);

if (do_mkdir)
    msf_mkdir(tmp_path);
end
