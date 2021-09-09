clear all;

% Define path for output folders
run_path = pwd;
framework_path = fileparts(fileparts(run_path));
pa_path = fullfile(framework_path,'tools','uvec','repulsion_angles');
out_path = fullfile(framework_path,'tools','uvec','repulsion_xyz');

for n = 10:128

    load(fullfile(pa_path,num2str(n)))

    out_fn = fullfile(out_path,[num2str(n) '.txt']);

    [out_path,out_name,out_ext] = fileparts(out_fn);
    if ~isdir(out_path)
        mkdir(out_path)
    end

    fid = fopen(out_fn,'w');


    out_mat = [cos(phi).*sin(theta) sin(phi).*sin(theta) cos(theta)];
    formatspec = '%8.6f %8.6f %8.6f\r\n';
    fprintf(fid, formatspec, out_mat');
    fclose(fid);

end
