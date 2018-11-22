function dtd_gamma_check_xps( xps )
% function dtd_gamma_check_xps( xps )

f = {'b_delta', 'b_eta', 'b', 'n'};

for c = 1:numel(f)
    assert( isfield( xps, f{c} ), ['xps.' f{c} ' required']);
end

if (isfield(xps, 's_ind'))
    us = unique(xps.s_ind);
    u_ind = bsxfun(@eq, xps.s_ind, 1:numel(us));
    t_ind = sum(u_ind, 2);
    
    assert( all(t_ind), 's_ind must be in continuous order!')
end