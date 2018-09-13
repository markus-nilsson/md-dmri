function guess = msf_fit_random_guess(fun_1d_fit2data, signal, xps, lb, ub, weight, iterations)
% function guess = msf_fit_random_guess(fun_1d_fit2data, signal, xps, lb, ub, weight, iterations)
% This functino takes a model and bounds, and randomizes a guess multiple
% times. The guess with the smallest residual is returned. This function is used
% when the initial guess must be random, but where poor initial guesses 
% must be avoided. Set iterations = 1 to get a conventional random guess.

if (nargin < 6) || (isempty(weight)), weight = ones(size(signal)); end 
if (nargin < 7), iterations = 100; end

thr = inf;

guess = [];

for j = 1:iterations
    m_rand = lb + (ub - lb) .* rand(size(lb));
    
    s_rand = fun_1d_fit2data(m_rand, xps);
    
    r_rand = sum(((signal-s_rand).*weight).^2);
    
    if r_rand < thr
        thr = r_rand;
        guess = m_rand;
    end
    
end
