function res_fn = elastix_run_transformix(i_fn, t_fn, o_path)
% function res_fn = elastix_run_transformix(i_fn, t_fn, o_path)
%
% Run transformix. For help, see readme.txt in the elastix folder.

cmd = 'transformix';
cmd = [cmd ' -in "'    i_fn    '"']; 
cmd = [cmd ' -out "'   o_path  '"']; 
cmd = [cmd ' -tp "'    t_fn    '"']; 

res_fn = fullfile(o_path, 'result.nii');




if (ismac) || (isunix)
    cmd_full = [getenv('SHELL') ' --login -c '' ' cmd ' '' '];   
else
    cmd_full = cmd;
end

msf_delete(res_fn);
[r, msg] = system(cmd_full);

msg_pos = strfind(msg, '------- Exception -');
if (~isempty(msg_pos))
    msg = msg(msg_pos:end);
    disp(msg);
    error('stop');
end

if (r ~= 0) || (~exist(res_fn, 'file'))
    disp(msg);
    msg = 'If elastix is not installed, check readme.txt in the elastix folder';
    error('%s\n%s\n\n%s\n%s\n%s\n', ...
        'Could not run TransformiX with command:', ...
        cmd_full, ...
        'If elastix is not installed, you will need to install it.', ...
        'Instructions for how to do this is found in the following file', ...
        fullfile(fileparts(mfilename('fullpath')), 'readme.txt'))
end

    
    
