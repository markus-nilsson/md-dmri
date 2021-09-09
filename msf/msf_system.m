function [status, result, cmd_full] = msf_system(cmd)
% function [status, result] = msf_system(cmd)
%
% Places a system call, works for Mac/PC

if (ismac) || (isunix)
    cmd_full = [getenv('SHELL') ' --login -c '' ' cmd ' '' '];
else
    cmd_full = cmd;
end

[status, result] = system(cmd_full);

