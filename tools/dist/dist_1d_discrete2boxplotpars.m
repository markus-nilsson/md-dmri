function dist_s = dist_1d_discrete2boxplotpars(dist_d)
% function dist_s = dist_1d_discrete2smooth(dist_d,dist_s)
%
% Convert from discrete to smooth 1D distribution. Gaussian convolution.
%
% dist_d discrete distribution  with fields
% dist_d.x vector of x-values
% dist_d.w vector of weights
% dist_s output smooth distribution with additional fields
% dist_s.w matrix of weights

dist_d.n = numel(dist_d.w);
dist_d.x(isnan(dist_d.x)) = 0;
dist_d.w(isnan(dist_d.w)) = 0;
meanx = sum(dist_d.w.*dist_d.x)/sum(dist_d.w);
stdx = std(dist_d.x,dist_d.w);
dist_s.x = meanx + 5*stdx*linspace(-1,1,1000);
dist_s.xsigma = 3*(dist_s.x(2) - dist_s.x(1));
dist_s = dist_1d_discrete2smooth(dist_d,dist_s);
dist_s.percentile = cumsum(dist_s.w)/sum(dist_s.w);
dist_s.xQ1 = dist_s.x(min(find(dist_s.percentile>.25)));
dist_s.xQ2 = dist_s.x(min(find(dist_s.percentile>.5)));
dist_s.xQ3 = dist_s.x(min(find(dist_s.percentile>.75)));
dist_s.xIQR = dist_s.xQ3 - dist_s.xQ1;
dist_s.xmax = max(dist_d.x(dist_d.x~=0));
dist_s.xmin = min(dist_d.x(dist_d.x~=0));
dist_s.xwhiskerup = min([dist_s.xmax dist_s.xQ2+1.5*dist_s.xIQR]);
dist_s.xwhiskerdown = max([dist_s.xmin dist_s.xQ2-1.5*dist_s.xIQR]);
