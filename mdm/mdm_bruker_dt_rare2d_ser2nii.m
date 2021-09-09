function mdm_bruker_dt_rare2d_ser2nii(data_path, nii_fn, rps)
% function mdm_bruker_dt_rare2d_ser2nii(data_path, nii_fn, rps)
%
% image reconstruction from Bruker DT_**rare2d pulse programs
% saves complex image as nifti file
% image resolution in field n.pixdim in nifti header
%
% data_path: folder where the Bruker ser file is located
% nii_fn: nifti file name (including complete path and extension)
% rps: image recon parameters structure
% rps.smooth : Gaussian smooting [m]
% rps.npix.read : image size in read dimension
% rps.npix.phase : image size in phase dimension

if nargin == 1, rps = []; end

% read acquistion parameters
load(fullfile(data_path,'NMRacqu2s'))
load(fullfile(data_path,'NMRacqus'))

td = 256*ceil(NMRacqus.td/256);
td1 = NMRacqu2s.td;
nbl = NMRacqus.nbl;
dw = 1/NMRacqus.sw_h/2;
t = 2*dw*(0:(td/2-1))';

tdim.tot = td/2*td1;

%%read time domain data and pick out relevant signal points
fid = fopen([data_path '/ser'],'r','ieee-le');
% if any(strcmp(NMRacqus.pulprog,{'DT_axderare2d','SM_moacrare2drs'}))
    Std1 = fread(fid,[2,tdim.tot],'long')';
% elseif any(strcmp(NMRacqus.pulprog,{'DT_axderare2d_av4'}))
%     Std1 = fread(fid,[2,tdim.tot],'float64')';
% end
%figure(1), clf, plot(1:numel(Std1),Std1(:)), return

Std1 = Std1(:,1) + 1i*Std1(:,2);
fclose(fid);
Std1 = reshape(Std1,td/2,td1);
S = Std1(:,1);

grpdlycount = (1:(td/2))'/(td/2) - floor(td/2/2);
zeroshiftfun = exp(-1i*(NMRacqus.grpdly*2*pi*grpdlycount));
zeroshiftfun = flipdim(zeroshiftfun,1);
zeroshiftfun = fftshift(zeroshiftfun,1);
S = fft(S,td/2,1);
S = zeroshiftfun.*S;
S = ifft(S,td/2,1);
%figure(1), clf, plot(1:td/2,real(S),1:td/2,imag(S)), return

tdim.i = NMRacqus.d40/NMRacqus.dw/2;
tdim.j = NMRacqus.l1;
tdim.ramp = NMRacqus.d32/dw/2;
tdim.fid = 2+(NMRacqus.d32+NMRacqus.d41)/dw/2;
tdim.phase = 2*NMRacqus.d32/dw/2;
tdim.slice = 4+NMRacqus.p12/1e6/dw/2;
tdim.read = NMRacqus.d40/dw/2;
tdim.init = tdim.fid + 2*tdim.phase + tdim.slice;
tdim.repeat = 2*tdim.phase + tdim.slice + tdim.read;

tdim.count.i = 1:tdim.i;
tdim.count.j = 0:(tdim.j-1);

[tdim.count.array.i,tdim.count.array.j] = ndgrid(tdim.count.i,tdim.count.j);
index.S = tdim.init + tdim.count.array.j*tdim.repeat + tdim.count.array.i;

S = reshape(S(index.S),tdim.i,tdim.j);
%figure(1), clf, plot(1:tdim.i,real(S(:,(tdim.j/2+1))),1:tdim.i,imag(S(:,(tdim.j/2+1)))), return


% Load gyromagnetic ratio gamma
gamma = mdm_bruker_gamma(NMRacqus);

% Load max gradient Gmax
Gmax = mdm_bruker_maxgradient(NMRacqus);

%%calculate k-space
%%read i
g.i = sqrt(NMRacqus.cnst11^2+NMRacqus.cnst12^2+NMRacqus.cnst13^2)*Gmax/100;
t_read = 2*dw*(0:(tdim.i-1))'; t_read = t_read-t_read(tdim.i/2+1);
k.i = gamma*g.i*t_read/2/pi;

%%phase j
g.j = linspace(-1,1,tdim.j+1)'*sqrt(NMRacqus.cnst21^2+NMRacqus.cnst22^2+NMRacqus.cnst23^2)*Gmax/100;
g.j = g.j(1:tdim.j);
t_phasenc = 0*NMRacqus.d33 + NMRacqus.d32;
k.j = gamma*g.j*t_phasenc/2/pi;

%%slice
g.slice = sqrt(NMRacqus.cnst31^2+NMRacqus.cnst32^2+NMRacqus.cnst33^2)*Gmax/100;

%%smoothing
if isfield(rps,'smooth')
    lb = rps.smooth;
else
    lb = 0;
end
lbfun.i = exp(-(lb*pi*k.i).^2);
lbfun.j = exp(-(lb*pi*k.j).^2);
%figure(1), clf, plot(k.i,lbfun.i,'o',k.j,lbfun.j,'s'), return

S = S - mean(mean(S([1:round(.1*tdim.i) round(.9*tdim.i):tdim.i],:)));

Stemp = S(:,tdim.j/2+1);
%figure(1), clf, plot(1:tdim.i,real(Stemp),1:tdim.i,imag(Stemp)), return
Stemp = lbfun.i.*Stemp;
%figure(1), clf, plot(k.i,real(Stemp),k.i,lbfun.i*max(real(Stemp))), return

if isfield(rps,'npix')
    nudim.i = rps.npix.read;
    nudim.j = rps.npix.phase;
else
    nudim.i = tdim.i;
    nudim.j = tdim.j;
end

index.tdim.i = 1:tdim.i;
if nudim.i<tdim.i
    index.tdim.i = .5*(tdim.i-nudim.i) + (1:nudim.i);
    Stemp = Stemp(index.tdim.i);
    k.i = k.i(index.tdim.i);
    lbfun.i = lbfun.i(index.tdim.i);
    %figure(1), clf,plot(k.i,real(Stemp),k.i,lbfun.i*max(real(Stemp))), return
end
index.tdim.j = 1:tdim.j;
if nudim.j<tdim.j
    index.tdim.j = .5*(tdim.j-nudim.j) + (1:nudim.j);
    k.j = k.j(index.tdim.j);
    lbfun.j = lbfun.j(index.tdim.j);
end

Itemp = fftshift(fft(Stemp,nudim.i));
%figure(1), clf, plot(abs(Itemp)), return

[k.array.i,k.array.j] = ndgrid(k.i,k.j);

if isfield(rps,'shift_read')
    shift_read = rps.shift_read;
else
    shift_read = -.25e-3;
end

lbfun.array = exp(-rps.smooth.^2*pi.^2*(k.array.i.^2 + k.array.j.^2));
phcorrfun.i = exp(shift_read*1i*2*pi*k.array.i);

S = S(index.tdim.i,index.tdim.j);

S = S.*lbfun.array.*phcorrfun.i;
%figure(1), clf, plot(real(squeeze(S(:,17)))), return

%%Fourier transform
if nudim.i > tdim.i
    Nzeros.i = nudim.i - tdim.i;
    S = [zeros(Nzeros.i/2,tdim.j); S; zeros(Nzeros.i/2,tdim.j)];
end
I = fftshift(fft(ifftshift(S,1),[],1),1);

if isfield(NMRacqus,'fq1')
    %fqcycle = 3480;
    %fqcycle = 1e10;
    if NMRacqus.dw == 5e-6, fqcycle = -2425;
    elseif NMRacqus.dw == 10e-6, fqcycle = -2340;
    end
    Nrep = td1/numel(NMRacqus.fq1);
    if Nrep>1, fq1list = repmat(NMRacqus.fq1,[Nrep 1]);
    else fq1list = NMRacqus.fq1(1:td1);
    end
    phcorrfun.j = repmat(exp(1i*2*pi*fq1list(1)/fqcycle*((1:tdim.j)-tdim.j/2-1)),[nudim.i 1]);
    I = phcorrfun.j.*I;
    r.slice = fq1list(1:nbl)./(gamma*g.slice/2/pi);
    resolution.slice = r.slice(2) - r.slice(1);
else
    resolution.slice = 1;
end

if nudim.j > tdim.j
    Nzeros.j = nudim.j - tdim.j;
    I = [zeros(nudim.i,Nzeros.j/2) I zeros(nudim.i,Nzeros.j/2)];
end
I = fftshift(fft(ifftshift(I,2),[],2),2);
%figure(1), clf, imagesc(abs(I)'), set(gca,'YDir','normal'), axis square, error('asdf')
r.i = .5/(k.i(2)-k.i(1))*linspace(-1,1,nudim.i+1)'; r.i = r.i(1:nudim.i);
r.j = .5/(k.j(2)-k.j(1))*linspace(-1,1,nudim.j+1)'; r.j = r.j(1:nudim.j);

resolution.i = r.i(2) - r.i(1);
resolution.j = r.j(2) - r.j(1);

Ninc = td1/nbl;
Itd1 = zeros(nudim.i,nudim.j,nbl,Ninc);
for ninc = 1:Ninc
    for nslice = 1:nbl
        ntd1 = (ninc-1)*nbl + nslice;
        S = Std1(:,ntd1);
        S = fft(S,td/2,1);
        S = zeroshiftfun.*S;
        S = ifft(S,td/2,1);
        S = reshape(S(index.S),tdim.i,tdim.j);
        S = S(index.tdim.i,index.tdim.j);
        S = S.*lbfun.array.*phcorrfun.i;
        if nudim.i > tdim.i
            S = [zeros(Nzeros.i/2,tdim.j); S; zeros(Nzeros.i/2,tdim.j)];
        end
        I = fftshift(fft(ifftshift(S,1),[],1),1);
        if isfield(NMRacqus,'fq1')
            phcorrfun.j = repmat(exp(1i*2*pi*fq1list(ntd1)/fqcycle*((1:tdim.j)-tdim.j/2-1)),[nudim.i 1]);
            I = phcorrfun.j.*I;
        end
        if nudim.j > tdim.j
            I = [zeros(nudim.i,Nzeros.j/2) I zeros(nudim.i,Nzeros.j/2)];
        end
        I = fftshift(fft(ifftshift(I,2),[],2),2);
        Itd1(:,:,nslice,ninc) = I;
        %figure(1), clf, imagesc(abs(I)'), set(gca,'YDir','normal'), axis square, title([num2str(ntd1) ' (' num2str(td1) ')']), pause(.1)
    end
end

Itd1 = abs(Itd1);

% make nifti headear
h = mdm_nii_h_empty;
sdim = size(Itd1);
h.pixdim(1+(1:length(sdim))) = sdim;
h.pixdim(2:4) = [resolution.i resolution.j resolution.slice];
h.xyzt_units = 'SI';

% write nifti image and header
mdm_nii_write(Itd1, nii_fn, h, 0);


