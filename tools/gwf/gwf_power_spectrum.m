function [ps,f,df] = gwf_power_spectrum(gwf, rf, dt, opt)
% function [ps,f,df] = gwf_power_spectrum(gwf, rf, dt)
%
% Compute the encoding power spectrum from q(t)
%
% Input
% q  - the q-trajectory
% dt - time step
%
% Output
% ps - encoding power spectrum
% f  - frequency axis
% df - frequency step

if (nargin < 4), opt = []; end
opt = gwf_opt(opt);


q = gwf_to_q(gwf, rf, dt, opt);

% zero fill before power computation
tmp = q;
tmp = cat(1, zeros(size(tmp)), tmp, zeros(size(tmp)));
tmp = cat(1, zeros(size(tmp)), tmp, zeros(size(tmp)));
tmp = cat(1, zeros(size(tmp)), tmp, zeros(size(tmp)));
tmp = cat(1, zeros(size(tmp)), tmp, zeros(size(tmp)));
q = tmp;


c = sqrt(2);

ps = zeros(size(q,1), 6);

if any(q(:,1))
    ps(:,1) = fftshift( fft(q(:,1) * dt) .* conj(fft(q(:,1) * dt, [], 1)) ) ;
end

if any(q(:,2))
    ps(:,2) = fftshift( fft(q(:,2) * dt) .* conj(fft(q(:,2) * dt, [], 1)) ) ;
    ps(:,4) = fftshift( fft(q(:,1) * dt) .* conj(fft(q(:,2) * dt, [], 1)) ) * c;
end

if any(q(:,3))
    ps(:,3) = fftshift( fft(q(:,3) * dt) .* conj(fft(q(:,3) * dt, [], 1)) ) ;
    ps(:,5) = fftshift( fft(q(:,1) * dt) .* conj(fft(q(:,3) * dt, [], 1)) ) * c;
    ps(:,6) = fftshift( fft(q(:,2) * dt) .* conj(fft(q(:,3) * dt, [], 1)) ) * c ;
end


f  = linspace(-1/dt, 1/dt, size(ps,1)) / 2;
df = f(2) - f(1);

