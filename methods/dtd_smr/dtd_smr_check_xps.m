function dtd_smr2_check_xps( xps )
% function dtd_smr2_check_xps( xps )
%
% xps-fields required: b_delta, b, and n

f = {'b_delta', 'b', 'te', 'n'};

for c = 1:numel(f)
    assert( isfield( xps, f{c} ), ['xps.' f{c} ' required']);
end

if (max(xps.b(:)) < 10)
    error('Maximal b-value too low (should be in SI units)');
end