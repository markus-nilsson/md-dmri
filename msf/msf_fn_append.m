function fn = msf_fn_append(fn, appendix)

[p,name,ext] = msf_fileparts(fn);

fn = fullfile(p, cat(2, name, appendix, ext));