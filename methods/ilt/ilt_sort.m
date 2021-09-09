function dtd_out = ilt_sort(dtd_in)

[n,D,w] = ilt_dist2par(dtd_in);

[wsort,ind] = sort(w,'descend');
ind = ind(wsort>0);

n = numel(ind);
D = D(ind);
w = w(ind);

dtd_out = [D'; w'];
dtd_out = [n; dtd_out(:)];
