function [path, name, ext] = msf_fileparts(fn)
% function [path, name, ext] = msf_fileparts(fn)
%
% Just as the built-in 'fileparts', except that this run fileparts twice in
% order to count '.nii.gz' as one extension

[path, name, ext] = fileparts(fn);

[~, name2, ext2] = fileparts(name);

if (strcmp(ext, '.gz') && strcmp(ext2, '.nii'))
    name = name2;
    ext = [ext2 ext];
end