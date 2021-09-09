function [D,dD,PD] = ilt_regularized_1d_data2fit(signal, xps, opt, ind)
% function m = ilt_regularized_1d_data2fit(signal, xps, opt, ind)

if (nargin < 4), ind = (signal > 0.1 * max(signal)); end

I = signal;

[M, D, dD, A] = ilt_regularized_inversion_kernel(xps);

PD = lsqnonneg(A,I);
Icalc = A*PD;
chisq = sum((Icalc-I).^2);
I = I/sqrt(chisq);

% Regularized smoothing type
SmoothMode = 4;
if SmoothMode==1
	H = []; f = [];
elseif SmoothMode==2
	H = eye(M,M); f = zeros(M,1);
elseif SmoothMode==3
	H = [-eye((M-1),M) zeros((M-1),1)] + [zeros((M-1),1) eye((M-1),M)]; H(:,(M+1))=[]; f = zeros((M-1),1);
elseif SmoothMode==4
	H = [eye((M-2),M) zeros((M-2),2)] + [zeros((M-2),1) -2*eye((M-2),M) zeros((M-2),1)] + [zeros((M-2),2) eye((M-2),M)]; H(:,(M+1):(M+2))=[]; f = zeros((M-2),1);
end

% Regularized smoothing
L = [1 zeros(1,(M-1)); zeros(1,(M-1)) 1];
l = zeros(2,1);
lambda = 1e1;
mu = 1;
muall = mu*logspace(-5,2,50);
for n = 1:length(muall)
    mu = muall(n);
    PD = lsqnonneg([A; mu*H; lambda*L],[I; f; l]);
    Icalc = A*PD;

    chisq = sum((Icalc-I).^2);
    %chisqsmooth = sum((f - mu*H*PD).^2);
    %chisqedge = sum((l - lambda*L*PD).^2);
    
    PDall(:,n) = PD;
    chisqall(n) = chisq;
    %chisqsmoothall(n) = chisqsmooth;
    %chisqedgeall(n) = chisqedge;
end

chisqratio = chisqall/min(chisqall);
pos = find(chisqratio>1.01);
pos = min(pos)-1;

PD = PDall(:,pos);
