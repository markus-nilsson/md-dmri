function [res_fn, tp_fn] = elastix_run_elastix(i_fn, ref_fn, p_fn, o_path, t0_fn, m_mask_fn, ref_mask_fn)
% function [res_fn, tp_fn] = elastix_run_elastix(i_fn, ref_fn, p_fn, o_path, t0_fn)
%
% Runs elastix. For help, see readme.txt in the elastix folder.

if (nargin < 5), t0_fn = []; end
if (nargin < 6), m_mask_fn = []; end
if (nargin < 6), ref_mask_fn = []; end



cmd = 'elastix';
cmd = [cmd ' -f "'   ref_fn  '"'];
cmd = [cmd ' -m "'   i_fn  '"'];
cmd = [cmd ' -out "' o_path '"'];
cmd = [cmd ' -p "'   p_fn  '"'];

% Optional initial transform and masking
if (~isempty(t0_fn)), cmd = [cmd ' -t0 "' t0_fn '"']; end
if ~isempty(ref_mask_fn), cmd = [cmd ' -fMask "' ref_mask_fn '"']; end
if ~isempty(m_mask_fn), cmd = [cmd ' -mMask "' m_mask_fn '"']; end

cmd = [cmd ' -threads 12'];


res_fn = fullfile(o_path, 'result.0.nii');
tp_fn  = fullfile(o_path, 'TransformParameters.0.txt');

if (~exist(p_fn, 'file'))
    error('did not find parameter file at %s', p_fn);
end

msf_delete({res_fn, tp_fn});

[r, msg, cmd_full] = msf_system(cmd); 




msg_pos = strfind(msg, 'itk::ExceptionObject');
if (~isempty(msg_pos))
    msg = msg(msg_pos:end);
    msg = msg(min(strfind(msg, sprintf('\n'))):end);
    disp(msg);
    error('stop');
end


if (r ~= 0) || (~exist(res_fn, 'file'))
    disp(msg);
    msg = 'If elastix is not installed, check readme.txt in the elastix folder';
    error('%s\n%s\n\n%s\n%s\n%s\n', ...
        'Could not run ElastiX with command:', ...
        cmd_full, ...
        'If elastix is not installed, you will need to install it.', ...
        'Instructions for how to do this is found in the following file', ...
        fullfile(fileparts(mfilename('fullpath')), 'readme.txt'))
end

