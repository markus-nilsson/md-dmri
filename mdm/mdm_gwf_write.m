function g = mdm_gwf_write(g, gwf_fn)
% function g = mdm_gwf_write(g, gwf_fn)
%
% g - size Nx3
% gwf_fn - gradient waveform filename

if (size(g,2) ~= 3)
    error('expected size(g) to be Nx3, found %i x %i', size(g,1), size(g,2));
end

if (any(abs(g(1,:)) > 0))
    error('First entry in g must be zero');
end

if (any(abs(g(1,end)) > 0))
    error('First entry in g must be zero');
end

fid = fopen(gwf_fn, 'w');
fprintf(fid, '%i\n', size(g,1));

for c = 1:size(g,1)
    fprintf(fid, '%f \t %f \t %f \n', g(c,1), g(c,2), g(c,3));
end

fclose(fid);
