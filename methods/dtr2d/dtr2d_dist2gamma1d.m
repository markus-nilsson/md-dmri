function gamma1d = dtd_dist2gamma1d(dtd,gamma1d)

dps1d = dtd_dist2dps1d(dtd);

mu2 = dps1d.viso + 4/5*dps1d.msqaniso + 1e-25;
kappa = dps1d.miso^2/mu2;
theta = mu2/dps1d.miso;

gamma1d.w = gampdf(gamma1d.d,kappa,theta);
gamma1d.w(gamma1d.d<0) = 0;
gamma1d.w = gamma1d.w/sum(gamma1d.w);
                              
dD = gamma1d.d(2) - gamma1d.d(1);

Dft = 1/dD*linspace(0,1,gamma1d.n)';
Dft = Dft - Dft(gamma1d.n/2+1);
wft = fftshift(fft(gamma1d.w,gamma1d.n,1),1);
sigmafun = exp(-(gamma1d.sigma*Dft*pi).^2);
wft = sigmafun.*wft;

gamma1d.w = real(ifft(ifftshift(wft,1),gamma1d.n,1));

wnorm = sum(gamma1d.w,1)*dD;
gamma1d.w = gamma1d.w./wnorm;
    