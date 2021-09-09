function dps1d = dtr1d_dist2dps1d(dtr1d)
% dps1d = dtr1d_dist2dps1d(dtr1d)
%
% Converts discrete diffusion tensor distribution to derived tensors and
% parameters. Equation numbers refer to definitions given in
% Topgaard. J. Magn. Reson. 275, 98 (2017).
% http://dx.doi.org/10.1016/j.jmr.2016.12.007
%
% Input arguments
% dtr1d: diffusion tensor distribution
%
% Output
% dps: derived parameters structure with fields
% s0: total amplitude = b0 signal
% miso: mean isotropic diffusivity, Eq (7.26)
% viso: variance of isotropic diffusivities, Eq (7.27)
% maniso: mean anisotropic diffusivity, Eq (7.28)
% vaniso: variance of anistropic diffusivities
% msqaniso: mean-square anisotropic diffusivity, Eq (7.29)
% vsqaniso: variance of squared anisotropic diffusivities
% t1x6: mean diffusion tensor in Voigt notation, 
% ct1x21: covariance tensor in Voigt-like notation, Eq (7.78)

dps1d.s0 = zeros([1 1]);
dps1d.t1x6 = zeros([1 6]);
dps1d.lambdazzvec = zeros([1 3]);
dps1d.lambdaxxvec = zeros([1 3]);
dps1d.lambdayyvec = zeros([1 3]);
dps1d.lambda11vec = zeros([1 3]);
dps1d.lambda22vec = zeros([1 3]);
dps1d.lambda33vec = zeros([1 3]);
dtiparam = {'trace','iso','lambda33','lambda22','lambda11','lambdazz','lambdaxx','lambdayy','vlambda',...
    'delta','eta','s','p','l','fa','cs','cl','cp','cm'};
param = {dtiparam{:},'miso','viso','maniso','vaniso','msqaniso','vsqaniso'};
for nparam = 1:numel(param)
    eval(['dps1d.' param{nparam} ' = zeros([1 1 1]);']);
end

[n,par,perp,theta,phi,r1,w] = dtr1d_dist2par(dtr1d);
if n > 0
    s0 = ones(1,n)*w;
    iso_v = (par + 2*perp)/3;
    miso = iso_v'*w/s0;
    viso = (iso_v-miso)'.^2*w/s0;
    aniso_v = (par - perp)/3;
    maniso = aniso_v'*w/s0;
    vaniso = (aniso_v-maniso)'.^2*w/s0;
    sqaniso_v = aniso_v.^2;
    msqaniso = sqaniso_v'*w/s0;
    vsqaniso = (sqaniso_v-msqaniso)'.^2*w/s0;                
    mr1 = r1'*w/s0;
    vr1 = (r1-mr1)'.^2*w/s0;

    dps1d.s0 = s0;
    dps1d.miso = miso;
    dps1d.viso = viso;
    dps1d.maniso = maniso;
    dps1d.vaniso = vaniso;
    dps1d.msqaniso = msqaniso;
    dps1d.vsqaniso = vsqaniso;
    dps1d.mr1 = mr1;
    dps1d.vr1 = vr1;

    [dtr1d_nx6,r1,w] = dtr1d_dist2nx6r1w(dtr1d);
    dt1x6 = (dtr1d_nx6'*w)'/s0;
    dt3x3 = tm_1x6_to_3x3(dt1x6);
    dt = tm_3x3_to_tpars(dt3x3);

    dps1d.t1x6(1,:) = dt.t1x6;
    dps1d.lambdazzvec(1,:) = dt.lambdazzvec;
    dps1d.lambdaxxvec(1,:) = dt.lambdaxxvec;
    dps1d.lambdayyvec(1,:) = dt.lambdayyvec;
    dps1d.lambda11vec(1,:) = dt.lambda11vec;
    dps1d.lambda22vec(1,:) = dt.lambda22vec;
    dps1d.lambda33vec(1,:) = dt.lambda33vec;
    for nparam = 1:numel(dtiparam)
        eval(['dps1d.' dtiparam{nparam} '(1) = dt.' dtiparam{nparam} ';']);
    end

    dt1x21 = tm_1x6_to_1x21(dt1x6);
    dtr1d_nx21 = tm_1x6_to_1x21(dtr1d_nx6);
    dps1d.ct1x21 = (dtr1d_nx21'*w)'/s0 - dt1x21;
    
end
    