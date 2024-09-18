function fn = msf_new_path(new_path, fn)

if (isempty(fn))
    fn = new_path;
    return;
end
    

[~,name,ext] = msf_fileparts(fn);

fn = fullfile(new_path, cat(2, name, ext));