function pake1d = dtd_dist2pake1d(dtd,pake1d)

[n,par,perp,theta,phi,w] = dtd_dist2par(dtd);
                              
dD = pake1d.d(2) - pake1d.d(1);

d_a = repmat(pake1d.d,[1 n]);
par_a = repmat(par',[pake1d.n 1]);
perp_a = repmat(perp',[pake1d.n 1]);
w_a = repmat(w,[pake1d.n 1]);

indx = find(abs(par_a-perp_a) < pake1d.sigma);
iso_a = (par_a + 2*perp_a)/3;
par_a(indx) = iso_a(indx) + .1*2*pake1d.sigma;
perp_a(indx) = iso_a(indx) - .1*pake1d.sigma;

k = 1./2./sqrt((par_a-perp_a).*(d_a - perp_a));
indx = find(d_a > max(cat(3,perp_a,par_a),[],3));
k(indx) = 0;
indx = find(d_a < min(cat(3,perp_a,par_a),[],3));
k(indx) = 0;

Dft = 1/dD*linspace(0,1,pake1d.n)';
Dft = Dft - Dft(pake1d.n/2+1);
wft = fftshift(fft(k,pake1d.n,1),1);
sigmafun = exp(-(pake1d.sigma*Dft*pi).^2);
sigmafunarray = repmat(sigmafun,1,n);
wft = sigmafunarray.*wft;

k = real(ifft(ifftshift(wft,1),pake1d.n,1));

wnorm = sum(k,1)*dD;
k = k./repmat(wnorm,pake1d.n,1);

pake1d.w = k*w;
    