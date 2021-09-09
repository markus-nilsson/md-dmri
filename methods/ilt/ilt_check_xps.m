function ilt_check_xps( xps )
% function dtd_ndi_check_xps( xps )
%
% required xps-fields: b and n

f = {'b', 'b_delta', 'n'};

for c = 1:numel(f)
    assert( isfield( xps, f{c} ), ['xps.' f{c} ' required']);
end

