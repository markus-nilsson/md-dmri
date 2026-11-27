% demo_vasco16_fit_and_plot.m
%
% Inspect one synthetic Vasco16 fit and, optionally, scan noiseless vd
% recovery over a paper-relevant vd range.
%
% This demo uses a precomputed xps structure derived from the bipolar
% FC/NC encoding scheme used for the Vasco16 example. xps can be generated
% from single gradient waveforms with gwf_to_pars. For multiple waveforms,
% per-waveform xps structures can be combined with mdm_xps_merge.

close all
clc

%% Settings

do_save = 1;        % 1: save figures, 0: do not save
do_vd_scan = 0;     % 1: run the optional noiseless vd recovery scan, 0: skip it

do_set_rng = 1;
rng_seed = 1;

fit_case = 'regularized'; % 'unregularized', 'regularized', or 'two_stage'
snr = 100;

figure_position_main = [120 120 400 500];
figure_position_scan = [180 180 400 360];
axis_label_font_size = 14;
title_font_size = 12;

d_blood_fixed = 1.75e-9;

% Single synthetic fit case shown in the main signal-versus-b plot.
% Order: [s0, vd2, f_blood, D_blood, D_tissue, w]
single_case_m_true = [1.00, (2e-3)^2, 0.05, d_blood_fixed, 0.90e-9, 1.00];

% Initial guess and bounds used by vasco16_1d_data2fit.
% Order: [s0, D_tissue, vd2, f_blood, w]
fit_guess = [1.0 0.9e-9 2.0e-6 0.05 1.0];
fit_lb = [0 0 0 0.00 0.5];
fit_ub = [2 3e-9 25e-6 1.00 1.5];
lambda_unregularized = 0.0;
lambda_regularized = 0.1;
lambda_two_stage = lambda_regularized;
reg_vd_lb = 0.75e-3;
reg_vd_ub = 2.75e-3;
reg_delta_vd = 0.4e-3;

dt_high_b_threshold_smm2 = 100;
dt_two_stage_rel_window = 0.010;

% Optional noiseless scan over true vd values using the same synthetic
% case, with only vd changed. The paper-relevant scan range is 0.75 to
% 2.75 mm/s.
vd_scan_grid_mm_per_s = linspace(0.75, 2.75, 25)';
vd_relative_error_threshold = 0.10;

%% Setup

example_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(fileparts(example_dir));
data_dir = fullfile(example_dir, 'data');
output_dir = fullfile(example_dir, 'output');
xps_fn = fullfile(data_dir, 'bipolar_fc_xps.mat');

addpath(repo_root);
setup_paths(0);
msf_mkdir(output_dir);

x = load(xps_fn);
if ~isfield(x, 'xps')
    error('xps missing in %s', xps_fn);
end
xps = x.xps;

opt = vasco16_opt(struct);
opt.vasco16.do_plot = 0;
opt.vasco16.dblood = d_blood_fixed;
opt.vasco16.fit_guess = fit_guess;
opt.vasco16.fit_lb = fit_lb;
opt.vasco16.fit_ub = fit_ub;
opt.vasco16.reg_vd_lb = reg_vd_lb;
opt.vasco16.reg_vd_ub = reg_vd_ub;
opt.vasco16.reg_delta_vd = reg_delta_vd;

fprintf('Setup\n');
fprintf('  fit_case     = %s\n', fit_case);
fprintf('  snr          = %s\n', local_snr_label(snr));
fprintf('  xps_fn       = %s\n', xps_fn);
fprintf('  fit_guess    = %s\n', mat2str(opt.vasco16.fit_guess, 6));
fprintf('  fit_lb       = %s\n', mat2str(opt.vasco16.fit_lb, 6));
fprintf('  fit_ub       = %s\n', mat2str(opt.vasco16.fit_ub, 6));
fprintf('  m_true       = %s\n', mat2str(single_case_m_true, 6));
fprintf('\n');

if do_set_rng
    rng(rng_seed, 'twister');
end

%% Single synthetic fit

m_true = single_case_m_true;
S_true = vasco16_1d_fit2data(m_true, xps);

if isinf(snr)
    noise_sigma = 0;
else
    noise_sigma = max(S_true) / snr;
end

S_obs = S_true + noise_sigma * randn(size(S_true));

switch fit_case
    case 'unregularized'
        opt.vasco16.reg_lambda = lambda_unregularized;

    case 'regularized'
        opt.vasco16.reg_lambda = lambda_regularized;

    case 'two_stage'
        opt.vasco16.reg_lambda = lambda_two_stage;

        fc_series_id = min(xps.s_ind(:));
        fc_mask = xps.s_ind == fc_series_id;
        b_fc_si = xps.b(fc_mask);
        s_fc = S_obs(fc_mask);
        high_b_mask = b_fc_si >= dt_high_b_threshold_smm2 * 1e6;

        if ~any(high_b_mask)
            error('No FC points found above Dt threshold.');
        end

        b_fit = b_fc_si(high_b_mask);
        s_fit = s_fc(high_b_mask);
        if any(s_fit <= 0) || numel(s_fit) < 2
            error('Cannot estimate Dt from FC high-b data.');
        end

        p = [ones(size(b_fit(:))) -b_fit(:)] \ log(s_fit(:));
        dt_est_si = p(2);
        dt_lb = max(fit_lb(2), dt_est_si * (1 - dt_two_stage_rel_window));
        dt_ub = min(fit_ub(2), dt_est_si * (1 + dt_two_stage_rel_window));

        opt.vasco16.fit_lb(2) = dt_lb;
        opt.vasco16.fit_ub(2) = dt_ub;
        opt.vasco16.fit_guess(2) = min(max(dt_est_si, dt_lb), dt_ub);

    otherwise
        error('Unknown fit_case: %s', fit_case);
end

m_fit = vasco16_1d_data2fit(S_obs, xps, opt);

vd_true_mm_per_s = sqrt(m_true(2)) * 1e3;
vd_fit_mm_per_s = sqrt(m_fit(2)) * 1e3;
fb_true = m_true(3);
fb_fit = m_fit(3);
dt_true_um2_per_ms = m_true(5) * 1e9;
dt_fit_um2_per_ms = m_fit(5) * 1e9;

fprintf('Single synthetic fit\n');
fprintf('  noise_sigma            %.6g\n', noise_sigma);
fprintf('  reg_lambda             %.6g\n', opt.vasco16.reg_lambda);
fprintf('  %-18s %8s %8s\n', 'parameter', 'true', 'fit');
fprintf('  %-18s %8.2f %8.2f\n', 'vd [mm/s]', vd_true_mm_per_s, vd_fit_mm_per_s);
fprintf('  %-18s %8.2f %8.2f\n', 'fb [%]', 100 * fb_true, 100 * fb_fit);
fprintf('  %-18s %8.2f %8.2f\n', 'Dt [um^2/ms]', dt_true_um2_per_ms, dt_fit_um2_per_ms);
fprintf('  relative error\n');
fprintf('    s0       %.6g\n', m_fit(1) / m_true(1) - 1);
fprintf('    vd2      %.6g\n', m_fit(2) / m_true(2) - 1);
fprintf('    fb       %.6g\n', m_fit(3) / m_true(3) - 1);
fprintf('    Dblood   %.6g\n', m_fit(4) / m_true(4) - 1);
fprintf('    Dtissue  %.6g\n', m_fit(5) / m_true(5) - 1);
fprintf('    w        %.6g\n', m_fit(6) / m_true(6) - 1);
fprintf('\n');

% Exclude the first b=0 point from FC/NC masking so the semilog plot stays well-behaved.
isb0 = (xps.b == 0);
isb0(find(isb0, 1, 'first')) = 0;

% FC is identified by near-zero alpha_norm. The remaining non-b0 points are NC.
isFC = (xps.alpha_norm < 1e-4) & ~isb0;
isNC = ~isFC;

b = xps.b / 1e6;
alpha2_over_b = round(100 * xps.alpha2 ./ (xps.b + eps)) / 100;
nfit = 256;
bmax = max(xps.b(:)) * 1.05;

S_true_fc = [];
S_true_nc = [];
S_fit_fc = [];
S_fit_nc = [];
b_fc = [];
b_nc = [];

if any(isFC)
    xps_fc = struct;
    xps_fc.b = linspace(eps, bmax, nfit)';
    xps_fc.alpha2 = median(alpha2_over_b(isFC)) * xps_fc.b;
    xps_fc.s_ind = median(xps.s_ind(isFC)) * ones(nfit, 1);
    S_true_fc = vasco16_1d_fit2data(m_true, xps_fc);
    S_fit_fc = vasco16_1d_fit2data(m_fit, xps_fc);
    b_fc = xps_fc.b / 1e6;
end

if any(isNC)
    xps_nc = struct;
    xps_nc.b = linspace(eps, bmax, nfit)';
    xps_nc.alpha2 = median(alpha2_over_b(isNC)) * xps_nc.b;
    xps_nc.s_ind = median(xps.s_ind(isNC)) * ones(nfit, 1);
    S_true_nc = vasco16_1d_fit2data(m_true, xps_nc);
    S_fit_nc = vasco16_1d_fit2data(m_fit, xps_nc);
    b_nc = xps_nc.b / 1e6;
end

fig1 = figure('Color', 'w', 'Position', figure_position_main);
ax1 = axes('Parent', fig1);
hold(ax1, 'on');

semilogy(ax1, b(isFC), S_obs(isFC) / m_true(1), 'ro', ...
    'MarkerFaceColor', 'r', 'MarkerSize', 6, 'LineWidth', 1.5);
semilogy(ax1, b(isNC), S_obs(isNC) / m_true(1), 'bo', ...
    'MarkerFaceColor', 'w', 'MarkerSize', 6, 'LineWidth', 1.5);

if ~isempty(S_true_fc)
    semilogy(ax1, b_fc, S_true_fc / m_true(1), 'r--', 'LineWidth', 1.5);
    semilogy(ax1, b_fc, S_fit_fc / m_true(1), 'r-', 'LineWidth', 2);
end

if ~isempty(S_true_nc)
    semilogy(ax1, b_nc, S_true_nc / m_true(1), 'b--', 'LineWidth', 1.5);
    semilogy(ax1, b_nc, S_fit_nc / m_true(1), 'b-', 'LineWidth', 2);
end

grid(ax1, 'off');
box(ax1, 'off');
set(ax1, 'TickDir', 'out');
xlabel(ax1, '$b\ [\mathrm{s/mm^2}]$', 'FontSize', axis_label_font_size, 'Interpreter', 'latex');
ylabel(ax1, '$S/S_0$', 'FontSize', axis_label_font_size, 'Interpreter', 'latex');
title(ax1, { ...
    sprintf('$\\mathrm{Single\\ synthetic\\ fit}\\ |\\ %s\\ |\\ \\mathrm{SNR}=%s$', ...
        local_fit_case_label_latex(fit_case), local_snr_label(snr)), ...
    sprintf('$\\mathrm{true:}\\ v_d=%.2f\\ \\mathrm{mm/s},\\ f_b=%.2f\\%%,\\ D_t=%.2f\\ \\mu\\mathrm{m}^2/\\mathrm{ms}$', ...
        vd_true_mm_per_s, 100 * fb_true, dt_true_um2_per_ms), ...
    sprintf('$\\mathrm{fit:}\\ v_d=%.2f\\ \\mathrm{mm/s},\\ f_b=%.2f\\%%,\\ D_t=%.2f\\ \\mu\\mathrm{m}^2/\\mathrm{ms}$', ...
        vd_fit_mm_per_s, 100 * fb_fit, dt_fit_um2_per_ms)}, ...
    'FontSize', title_font_size, 'FontWeight', 'bold', 'Interpreter', 'latex');
legend(ax1, {'$\mathrm{FC\ data}$', '$\mathrm{NC\ data}$', '$\mathrm{FC\ true}$', '$\mathrm{FC\ fit}$', '$\mathrm{NC\ true}$', '$\mathrm{NC\ fit}$'}, ...
    'Location', 'best', 'Box', 'off', 'Interpreter', 'latex');

if do_save
    png_fn1 = fullfile(output_dir, 'demo_vasco16_fit_and_plot.png');
    saveas(fig1, png_fn1);
    fprintf('Saved plot: %s\n', png_fn1);
end

%% Optional vd scan

if do_vd_scan
    base_m = m_true;

    m_fit_all = zeros(numel(vd_scan_grid_mm_per_s), 6);
    relative_error_all = zeros(numel(vd_scan_grid_mm_per_s), 6);
    rmse_all = zeros(numel(vd_scan_grid_mm_per_s), 1);

    for i = 1:numel(vd_scan_grid_mm_per_s)
        m_scan = base_m;
        m_scan(2) = (vd_scan_grid_mm_per_s(i) * 1e-3)^2;

        s_scan = vasco16_1d_fit2data(m_scan, xps);
        m_fit_scan = vasco16_1d_data2fit(s_scan, xps, opt);
        s_fit_scan = vasco16_1d_fit2data(m_fit_scan, xps);

        m_fit_all(i, :) = m_fit_scan;
        relative_error_all(i, 1) = m_fit_scan(1) / m_scan(1) - 1;
        relative_error_all(i, 2) = sqrt(m_fit_scan(2)) * 1e3 / vd_scan_grid_mm_per_s(i) - 1;
        relative_error_all(i, 3:6) = m_fit_scan(3:6) ./ m_scan(3:6) - 1;
        rmse_all(i) = sqrt(mean((s_fit_scan - s_scan).^2));
    end

    scan_table = table((vd_scan_grid_mm_per_s(:) * 1e-3).^2, vd_scan_grid_mm_per_s, m_fit_all(:,2), sqrt(m_fit_all(:,2)) * 1e3, ...
        relative_error_all(:,2), rmse_all, ...
        'VariableNames', {'v2_true', 'vd_true_mm_per_s', 'v2_fit', 'vd_fit_mm_per_s', 'vd_relative_error', 'rmse_signal'});

    disp(scan_table);

    fig2 = figure('Color', 'w', 'Position', figure_position_scan);
    ax2 = axes('Parent', fig2);
    plot(ax2, vd_scan_grid_mm_per_s, relative_error_all(:,2), 'k.-', ...
        'LineWidth', 1.5, 'MarkerSize', 14);
    hold(ax2, 'on');
    yline(ax2, vd_relative_error_threshold, 'r--');
    yline(ax2, -vd_relative_error_threshold, 'r--');
    grid(ax2, 'on');
    box(ax2, 'off');
    set(ax2, 'TickDir', 'out');
    xlabel(ax2, '$v_d\ \mathrm{true}\ [\mathrm{mm/s}]$', 'FontSize', axis_label_font_size, 'Interpreter', 'latex');
    ylabel(ax2, '$v_d\ \mathrm{relative\ error}=v_{d,\mathrm{fit}}/v_{d,\mathrm{true}}-1$', ...
        'FontSize', axis_label_font_size, 'Interpreter', 'latex');
    title(ax2, { ...
        sprintf('$\\mathrm{Noiseless}\\ v_d\\ \\mathrm{recovery\\ scan}\\ |\\ %s$', ...
            local_fit_case_label_latex(fit_case)), ...
        sprintf('$v_d\\in[0.75,2.75]\\ \\mathrm{mm/s},\\ \\pm %.2f\\ \\mathrm{guides\\ shown\\ in\\ red}$', ...
            vd_relative_error_threshold)}, ...
        'FontSize', title_font_size, 'FontWeight', 'bold', 'Interpreter', 'latex');

    if do_save
        png_fn2 = fullfile(output_dir, 'demo_vasco16_vd_scan.png');
        saveas(fig2, png_fn2);
        fprintf('Saved plot: %s\n', png_fn2);
    end
end

function s = local_snr_label(snr)
if isinf(snr)
    s = 'inf';
else
    s = sprintf('%.3g', snr);
end
end

function s = local_fit_case_label_latex(fit_case)
switch fit_case
    case 'unregularized'
        s = '\mathrm{unregularized}';
    case 'regularized'
        s = '\mathrm{regularized}';
    case 'two_stage'
        s = '\mathrm{two\mbox{-}stage}';
    otherwise
        error('Unknown fit_case: %s', fit_case);
end
end
