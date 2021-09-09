function fsl_applytopup(input_fn1, input_fn2, topup_data_path, ...
    topup_spec_fn, output_fn, opt)
% function fsl_applytopup(input_fn1, input_fn2, topup_data_path, ...
%     topup_spec_fn, output_fn, opt)

opt = fsl_opt(opt);
msf_log(['Starting ' mfilename], opt);

% Test input args
if (opt.assert_input_args)
    [~,~,ext] = fileparts(topup_data_path);
    if (numel(ext) ~= 0)
        error('topup_data_path should have no extension (now: %s)', ext);
    end
end

% Test if  output exists 
if (~opt.do_overwrite && (exist(output_fn, 'file')))
    disp(['Skipping, output file already exists: ' output_fn]);
    return;
end


% Allow for application to main data acquired with one phase direction
% only
if (isempty(input_fn1) && isempty(input_fn2))
    error('both input filenames cannot be empty');
end

if (~isempty(input_fn1))
    do_clear_input_fn1 = 0;
else
    do_clear_input_fn1 = 1;
    input_fn1 = fullfile(msf_tmp_path(), 'z1.nii.gz');
    [I,h] = mdm_nii_read(input_fn2);
    mdm_nii_write(single(0.001 * ones(size(I))), input_fn1, h);
end

if (~isempty(input_fn2))
    do_clear_input_fn2 = 0;
else
    do_clear_input_fn2 = 1;
    input_fn2 = fullfile(msf_tmp_path(), 'z2.nii.gz');
    [I,h] = mdm_nii_read(input_fn1);
    mdm_nii_write(single(0.001 * ones(size(I))), input_fn2, h);
end

% Define command
cmd = sprintf([getenv('SHELL') ' --login -c ''applytopup ' ...
    '--imain=%s,%s --inindex=1,2 --topup=%s --datain=%s --out=%s'''], ...
    input_fn1, ...          % imain_1
    input_fn2, ...          % imain_2
    topup_data_path, ...    % topup
    topup_spec_fn, ...      % spec
    output_fn);             % output_fn

me = [];

try
    system(cmd);
catch me
    1; % deal with this error later
end

if (do_clear_input_fn1), msf_delete(input_fn1); end
if (do_clear_input_fn2), msf_delete(input_fn2); end


if (~isempty(me)), rethrow(me); end


