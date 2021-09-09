function dti_euler_plot(S, xps, axh, axh2, opt)
% function dti_euler_plot(S, xps, axh, axh2)

if (nargin < 5), opt = []; end
if (nargin < 4), axh2 = []; end

opt = mdm_opt();
opt = dti_euler_opt(opt);
opt = mplot_opt(opt);

% Customize options
% opt.dtd.dmin = .05/max(xps.b);

S = abs(S);

% Show signal and fit
m = mplot_signal_and_fit(S, xps, @dti_euler_1d_data2fit, @dti_euler_1d_fit2data, axh, opt);


s0 = m(1);
lambdaxx = m(2);
lambdayy = m(3);
lambdazz = m(4);
alpha = angle(exp(1i*m(5)));
beta  = angle(exp(1i*m(6)));
gamma = angle(exp(1i*m(7)));

[rotmat,rotmatinv] = tm_euler_angles2rotmat(alpha,beta,gamma);

dt_lambda = diag([lambdaxx, lambdayy, lambdazz]);

dt3x3 = rotmat*dt_lambda*rotmatinv;
dt = tm_3x3_to_tpars(dt3x3);

title_str = {...
    ['MD = ' num2str(dt.iso/1e-9, 2) ' ',char(181),'m^2/ms']; ...
    ['FA = ' num2str(dt.fa, 2)]};

title(axh, title_str)
axis(axh2, 'off');