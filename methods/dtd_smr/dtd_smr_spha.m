function [Ylm] = smr_spha(l, m, theta, phi)
%
% Original author: bjian
%

% Assume that m > 0, but store the sign
m_signed = m;
m        = abs(m_signed);

% Constant factor
a1 = (2 * l + 1) / (4 * pi);
a2 = factorial(l - m) / factorial(l + m);
c = sqrt(a1*a2);

% l-part                        
Plm = legendre(l,cos(theta));    % m    = [0 1 2 ...]
if l~=0
    Plm = Plm(m+1,:); % extract correct associated
end

Plm = Plm(:);

% m-part
em = exp(1i * m * phi);

% Combine
Ylm = c * Plm .* em;

% Correct for negative m
if (m_signed < 0)
    Ylm = (-1)^m * conj(Ylm);    
end
end