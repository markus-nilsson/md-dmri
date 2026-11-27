% demo_vasco16_fit_evaluation.m

% Evaluate fitting variants for the Ahlgren et al. (2016) FC/NC IVIM
% velocity-dispersion model.
%
% The script uses synthetic flow-compensated (FC) and non-flow-compensated
% (NC) data and compares variants of joint FC/NC analysis.
%
% This demo uses a precomputed xps structure derived from the bipolar
% FC/NC encoding scheme used for the Vasco16 example. xps can be generated
% from single gradient waveforms with gwf_to_pars. For multiple waveforms,
% per-waveform xps structures can be combined with mdm_xps_merge.

%% Settings

do_generate = 1;  % 1: generate synthetic data and fit, 0: load saved results only
do_save = 1;      % 1: save figures and summaries, 0: do not save

% Fit cases to compare.
% unregularized: joint FC/NC fit without vd regularization
% regularized: joint FC/NC fit with soft vd regularization
% two_stage: first estimate Dt from FC high-b data, then use it in the constrained joint FC/NC fit

% Regularization is a soft penalty on vd during the nonlinear fit.
% It penalizes vd values outside [reg_vd_lb, reg_vd_ub].
% reg_delta_vd controls the smooth transition width of the penalty.
% reg_lambda controls the penalty weight.

fit_cases = {'unregularized', 'regularized', 'two_stage'};

% Acquisition used in this synthetic FC/NC example.
b_smm2 = [0 10 20 30 40 50 60 70 80 90 100 120 140 160 180 200];

% Parameter arrays for the evaluation grid.
vd_um_per_ms = linspace(0.75, 2.75, 11);
f_blood = linspace(0.01, 0.10, 10);
d_tissue_um2_per_ms = [0.7 1.0 1.3];

% Noise settings.
snr = 100;
N_SNR = 100;

% Manual signal-versus-b cases for inspection plots.
signal_demo_vd_um_per_ms = [1.75];
signal_demo_fb = [0.05];
signal_demo_d_tissue_um2_per_ms = [1.0];

% Fixed fit parameters for synthetic data.
s0 = 1.0;
w = 1.0; % s0_FC/s0_NC (relative scaling between FC and NC signal amplitudes)
d_blood_um2_per_ms = 1.75;

% Initial guess and bounds used by vasco16_1d_data2fit.
% Order: [s0, D_tissue, vd2, f_blood, w]
fit_guess = [1.0 0.9e-9 (1.75e-3)^2 0.05 1.0];
fit_lb = [0 0 0 0 0.5];
fit_ub = [2 3e-9 (5e-3)^2 1 1.5];

% Regularization settings. The regularization window is defined on vd.
lambda_unregularized = 0.0;
lambda_regularized = 0.1;
lambda_two_stage = lambda_regularized;
reg_vd_lb = 0.75e-3;
reg_vd_ub = 2.75e-3;
reg_delta_vd = 0.4e-3;

% Two-stage Dt estimate settings.
dt_high_b_threshold_smm2 = 100;
dt_two_stage_rel_window = 0.010;

% Color limits for the bias figure.
clim_vd_bias_pct = [-20 20];
clim_fb_bias_pct = [-20 20];
clim_rmse_mean = [];

% Color limits for the standard-deviation figure.
clim_vd_std = [];
clim_fb_std = [];
clim_rmse_std = [];

% Figure settings.
figure_numbers_bias = [1 2 3];
figure_numbers_std = [4 5 6];
figure_position = [80 80 700 600];
panel_title_font_size = 12;
figure_title_font_size = 12;
axis_label_font_size = 14;
signal_figure_number_start = 11;
signal_figure_position = [120 120 400 500];
signal_realization_to_plot = 1; % which noise realization to highlight when N_SNR > 1

%% Paths and FC/NC setup

example_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(fileparts(example_dir));
data_dir = fullfile(example_dir, 'data');
output_dir = fullfile(example_dir, 'output');
bipolar_xps_fn = fullfile(data_dir, 'bipolar_fc_xps.mat');

fc_series_id = 1;
nc_series_id = 2;

addpath(repo_root);
setup_paths(0);
msf_mkdir(output_dir);

alpha2_over_b_nc = local_resolve_fc_ratio(bipolar_xps_fn, nc_series_id);
xps = local_make_demo_xps(b_smm2, alpha2_over_b_nc, fc_series_id, nc_series_id);
if isinf(snr)
    snr_label = 'inf';
else
    snr_label = sprintf('%.3g', snr);
end
snr_tag = ['snr_' strrep(snr_label, '.', 'p')];
n_snr_tag = sprintf('n_%d', N_SNR);

fprintf('Repo-fitter recovery demo\n');
fprintf('  fit cases            %s\n', strjoin(fit_cases, ', '));
fprintf('  b [s/mm^2]           %s\n', mat2str(b_smm2, 6));
fprintf('  vd [um/ms]           [%g %g], N=%d\n', ...
    vd_um_per_ms(1), vd_um_per_ms(end), numel(vd_um_per_ms));
fprintf('  fb                   [%g %g], N=%d\n', ...
    f_blood(1), f_blood(end), numel(f_blood));
fprintf('  Dt columns [um^2/ms] %s\n', mat2str(d_tissue_um2_per_ms, 6));
fprintf('  lambdas              [unreg=%.3g, reg=%.3g, two_stage=%.3g]\n', ...
    lambda_unregularized, lambda_regularized, lambda_two_stage);
fprintf('  snr                  %s\n', snr_label);
fprintf('  N_SNR                %d\n', N_SNR);
fprintf('  xps_fn               %s\n', bipolar_xps_fn);
for i_case = 1:numel(signal_demo_vd_um_per_ms)
    fprintf('  manual signal case %d [vd=%.3g um/ms, fb=%.3g, Dt=%.3g um^2/ms]\n', ...
        i_case, signal_demo_vd_um_per_ms(i_case), signal_demo_fb(i_case), signal_demo_d_tissue_um2_per_ms(i_case));
end
fprintf('\n');

n_mode = numel(fit_cases);
n_dt = numel(d_tissue_um2_per_ms);
n_f = numel(f_blood);
n_vd = numel(vd_um_per_ms);
n_signal = xps.n;
n_vox = n_dt * n_f * n_vd;

save_fn = fullfile(output_dir, sprintf('demo_vasco16_fit_evaluation_results_%s_%s.mat', snr_tag, n_snr_tag));
summary_txt_fn = fullfile(output_dir, sprintf('demo_vasco16_fit_evaluation_summary_%s_%s.txt', snr_tag, n_snr_tag));

%% Generate or Load data
tic
if do_generate
    fc_mask = xps.s_ind == fc_series_id;
    b_fc_si = xps.b(fc_mask);

    signal_true_flat = zeros(n_signal, n_vox);
    signal_obs_flat = zeros(n_signal, n_vox, N_SNR);
    signal_fit_flat = zeros(n_signal, n_vox, n_mode, N_SNR);
    signal_prefit_flat = nan(n_signal, n_vox, n_mode, N_SNR);
    m_fit_flat = zeros(6, n_vox, n_mode, N_SNR);
    vd_pct_flat = zeros(n_vox, n_mode, N_SNR);
    fb_pct_flat = zeros(n_vox, n_mode, N_SNR);
    rmse_flat = zeros(n_vox, n_mode, N_SNR);
    dt_fit_flat = zeros(n_vox, n_mode, N_SNR);

    parfor i_vox = 1:n_vox
        [signal_true_flat(:, i_vox), signal_obs_flat(:, i_vox, :), ...
            signal_fit_flat(:, i_vox, :, :), signal_prefit_flat(:, i_vox, :, :), ...
            m_fit_flat(:, i_vox, :, :), vd_pct_flat(i_vox, :, :), ...
            fb_pct_flat(i_vox, :, :), rmse_flat(i_vox, :, :), dt_fit_flat(i_vox, :, :)] = ...
            local_fit_one_voxel(i_vox, xps, n_dt, n_f, n_vd, d_tissue_um2_per_ms, ...
            f_blood, vd_um_per_ms, s0, w, d_blood_um2_per_ms, snr, N_SNR, ...
            n_mode, fit_cases, fit_guess, fit_lb, fit_ub, reg_vd_lb, reg_vd_ub, ...
            reg_delta_vd, lambda_unregularized, lambda_regularized, ...
            lambda_two_stage, dt_high_b_threshold_smm2, dt_two_stage_rel_window, ...
            fc_series_id);
    end

    signal_true_all = permute(reshape(signal_true_flat, [n_signal, n_dt, n_f, n_vd]), [1 3 4 2]);
    signal_obs_all = permute(reshape(signal_obs_flat, [n_signal, n_dt, n_f, n_vd, N_SNR]), [1 3 4 2 5]);
    signal_fit_all = permute(reshape(signal_fit_flat, [n_signal, n_dt, n_f, n_vd, n_mode, N_SNR]), [1 3 4 2 5 6]);
    signal_prefit_all = permute(reshape(signal_prefit_flat, [n_signal, n_dt, n_f, n_vd, n_mode, N_SNR]), [1 3 4 2 5 6]);
    m_fit_all = permute(reshape(m_fit_flat, [6, n_dt, n_f, n_vd, n_mode, N_SNR]), [1 3 4 2 5 6]);
    vd_pct = permute(reshape(vd_pct_flat, [n_dt, n_f, n_vd, n_mode, N_SNR]), [2 3 1 4 5]);
    fb_pct = permute(reshape(fb_pct_flat, [n_dt, n_f, n_vd, n_mode, N_SNR]), [2 3 1 4 5]);
    rmse = permute(reshape(rmse_flat, [n_dt, n_f, n_vd, n_mode, N_SNR]), [2 3 1 4 5]);
    dt_fit_um2_per_ms = permute(reshape(dt_fit_flat, [n_dt, n_f, n_vd, n_mode, N_SNR]), [2 3 1 4 5]);
else
    load(save_fn, ...
        'fit_cases', 'b_smm2', 'vd_um_per_ms', 'f_blood', 'd_tissue_um2_per_ms', ...
        'vd_pct', 'fb_pct', 'rmse', 'dt_fit_um2_per_ms', ...
        'signal_true_all', 'signal_obs_all', 'signal_fit_all', 'signal_prefit_all', 'm_fit_all', ...
        'snr', 'N_SNR', 'xps');
    n_mode = numel(fit_cases);
    n_dt = numel(d_tissue_um2_per_ms);
    n_f = numel(f_blood);
    n_vd = numel(vd_um_per_ms);
    n_signal = xps.n;
end
toc

%% Summary and Figures

summary_lines = {};
summary_lines{end+1} = 'Vasco16 fit evaluation summary';
summary_lines{end+1} = '';
summary_lines{end+1} = sprintf('fit cases: %s', strjoin(fit_cases, ', '));
summary_lines{end+1} = sprintf('b [s/mm^2]: %s', mat2str(b_smm2, 6));
summary_lines{end+1} = sprintf('Nb: %d, bmin: %.6g, bmax: %.6g', numel(b_smm2), min(b_smm2), max(b_smm2));
summary_lines{end+1} = sprintf('vd range [um/ms]: [%.6g %.6g], N=%d', vd_um_per_ms(1), vd_um_per_ms(end), numel(vd_um_per_ms));
summary_lines{end+1} = sprintf('fb range: [%.6g %.6g], N=%d', f_blood(1), f_blood(end), numel(f_blood));
summary_lines{end+1} = sprintf('Dt values [um^2/ms]: %s', mat2str(d_tissue_um2_per_ms, 6));
summary_lines{end+1} = sprintf('lambdas: [unreg=%.6g, reg=%.6g, two_stage=%.6g]', ...
    lambda_unregularized, lambda_regularized, lambda_two_stage);
summary_lines{end+1} = sprintf('snr: %s', snr_label);
summary_lines{end+1} = sprintf('N_SNR: %d', N_SNR);
summary_lines{end+1} = '';

for i_mode = 1:n_mode
    mode_name = fit_cases{i_mode};
    mode_vd_bias = mean(vd_pct(:,:,:,i_mode,:), 5);
    mode_fb_bias = mean(fb_pct(:,:,:,i_mode,:), 5);
    mode_rmse_mean = mean(rmse(:,:,:,i_mode,:), 5);

    fig = figure(figure_numbers_bias(i_mode)); clf(fig);
    set(fig, 'Color', 'w', 'Position', figure_position);
    tl = tiledlayout(3, n_dt, 'TileSpacing', 'compact', 'Padding', 'compact');

    clim1 = local_pick_row_clim(mode_vd_bias, clim_vd_bias_pct, 1);
    clim2 = local_pick_row_clim(mode_fb_bias, clim_fb_bias_pct, 1);
    clim3 = local_pick_row_clim(mode_rmse_mean, clim_rmse_mean, 0);

    for i_dt = 1:n_dt
        ax = nexttile(tl, i_dt);
        imagesc(ax, vd_um_per_ms, f_blood * 100, mode_vd_bias(:,:,i_dt));
        axis(ax, 'xy');
        axis(ax, 'square');
        set(ax, 'TickDir', 'out');
        caxis(ax, clim1);
        if i_dt == 1
            ylabel(ax, '$f_b$ true [\%]', 'FontSize', axis_label_font_size, 'Interpreter', 'latex');
        else
            set(ax, 'YTickLabel', []);
        end
        title(ax, sprintf('$D_t = %.2f\\,\\mu\\mathrm{m}^2/\\mathrm{ms}$', d_tissue_um2_per_ms(i_dt)), ...
            'FontSize', panel_title_font_size, 'FontWeight', 'bold', 'Interpreter', 'latex');
        if i_dt == n_dt
            cb = colorbar(ax);
            ylabel(cb, '$v_d$ bias [\%]', 'FontSize', axis_label_font_size, 'Interpreter', 'latex');
        end

        ax = nexttile(tl, n_dt + i_dt);
        imagesc(ax, vd_um_per_ms, f_blood * 100, mode_fb_bias(:,:,i_dt));
        axis(ax, 'xy');
        axis(ax, 'square');
        set(ax, 'TickDir', 'out');
        caxis(ax, clim2);
        if i_dt == 1
            ylabel(ax, '$f_b$ true [\%]', 'FontSize', axis_label_font_size, 'Interpreter', 'latex');
        else
            set(ax, 'YTickLabel', []);
        end
        if i_dt == n_dt
            cb = colorbar(ax);
            ylabel(cb, '$f_b$ bias [\%]', 'FontSize', axis_label_font_size, 'Interpreter', 'latex');
        end

        ax = nexttile(tl, 2 * n_dt + i_dt);
        imagesc(ax, vd_um_per_ms, f_blood * 100, mode_rmse_mean(:,:,i_dt));
        axis(ax, 'xy');
        axis(ax, 'square');
        set(ax, 'TickDir', 'out');
        caxis(ax, clim3);
        xlabel(ax, '$v_d$ true [$\mu$m/ms]', 'FontSize', axis_label_font_size, 'Interpreter', 'latex');
        if i_dt == 1
            ylabel(ax, '$f_b$ true [\%]', 'FontSize', axis_label_font_size, 'Interpreter', 'latex');
        else
            set(ax, 'YTickLabel', []);
        end
        if i_dt == n_dt
            cb = colorbar(ax);
            ylabel(cb, '$\mathrm{mean\ signal\ RMSE}$', 'FontSize', axis_label_font_size, 'Interpreter', 'latex');
        end
    end

    title(tl, sprintf('Bias | %s | $b_{\\max}=%g\\,\\mathrm{s/mm^2}$ | SNR=%s | $N=%d$', ...
        local_mode_label(mode_name, lambda_unregularized, lambda_regularized, lambda_two_stage), ...
        max(b_smm2), snr_label, N_SNR), ...
        'FontSize', figure_title_font_size, 'FontWeight', 'bold', 'Interpreter', 'latex');

    if do_save
        png_fn = fullfile(output_dir, sprintf('demo_vasco16_fit_evaluation_bias_%s_%s_%s.png', mode_name, snr_tag, n_snr_tag));
        saveas(fig, png_fn);
        fprintf('Saved figure: %s\n', png_fn);
    end

    [stats, summary_block_lines] = local_collect_summary( ...
        mode_name, mode_vd_bias, mode_fb_bias, mode_rmse_mean, ...
        vd_pct(:,:,:,i_mode,:), fb_pct(:,:,:,i_mode,:), rmse(:,:,:,i_mode,:), ...
        vd_um_per_ms, f_blood, d_tissue_um2_per_ms, lambda_unregularized, lambda_regularized, lambda_two_stage);
    local_print_summary(stats);
    summary_lines = [summary_lines, summary_block_lines, {''}]; 

    if N_SNR > 1
        mode_vd_std = std(vd_pct(:,:,:,i_mode,:), 0, 5);
        mode_fb_std = std(fb_pct(:,:,:,i_mode,:), 0, 5);
        mode_rmse_std = std(rmse(:,:,:,i_mode,:), 0, 5);

        fig = figure(figure_numbers_std(i_mode)); clf(fig);
        set(fig, 'Color', 'w', 'Position', figure_position);
        tl = tiledlayout(3, n_dt, 'TileSpacing', 'compact', 'Padding', 'compact');

        clim1 = local_pick_row_clim(mode_vd_std, clim_vd_std, 0);
        clim2 = local_pick_row_clim(mode_fb_std, clim_fb_std, 0);
        clim3 = local_pick_row_clim(mode_rmse_std, clim_rmse_std, 0);

        for i_dt = 1:n_dt
            ax = nexttile(tl, i_dt);
            imagesc(ax, vd_um_per_ms, f_blood * 100, mode_vd_std(:,:,i_dt));
            axis(ax, 'xy');
            axis(ax, 'square');
            set(ax, 'TickDir', 'out');
            caxis(ax, clim1);
            if i_dt == 1
                ylabel(ax, '$f_b$ true [\%]', 'FontSize', axis_label_font_size, 'Interpreter', 'latex');
            else
                set(ax, 'YTickLabel', []);
            end
            title(ax, sprintf('$D_t = %.2f\\,\\mu\\mathrm{m}^2/\\mathrm{ms}$', d_tissue_um2_per_ms(i_dt)), ...
                'FontSize', panel_title_font_size, 'FontWeight', 'bold', 'Interpreter', 'latex');
            if i_dt == n_dt
                cb = colorbar(ax);
                ylabel(cb, '$v_d$ std [\%]', 'FontSize', axis_label_font_size, 'Interpreter', 'latex');
            end

            ax = nexttile(tl, n_dt + i_dt);
            imagesc(ax, vd_um_per_ms, f_blood * 100, mode_fb_std(:,:,i_dt));
            axis(ax, 'xy');
            axis(ax, 'square');
            set(ax, 'TickDir', 'out');
            caxis(ax, clim2);
            if i_dt == 1
                ylabel(ax, '$f_b$ true [\%]', 'FontSize', axis_label_font_size, 'Interpreter', 'latex');
            else
                set(ax, 'YTickLabel', []);
            end
            if i_dt == n_dt
                cb = colorbar(ax);
                ylabel(cb, '$f_b$ std [\%]', 'FontSize', axis_label_font_size, 'Interpreter', 'latex');
            end

            ax = nexttile(tl, 2 * n_dt + i_dt);
            imagesc(ax, vd_um_per_ms, f_blood * 100, mode_rmse_std(:,:,i_dt));
            axis(ax, 'xy');
            axis(ax, 'square');
            set(ax, 'TickDir', 'out');
            caxis(ax, clim3);
            xlabel(ax, '$v_d$ true [$\mu$m/ms]', 'FontSize', axis_label_font_size, 'Interpreter', 'latex');
            if i_dt == 1
                ylabel(ax, '$f_b$ true [\%]', 'FontSize', axis_label_font_size, 'Interpreter', 'latex');
            else
                set(ax, 'YTickLabel', []);
            end
            if i_dt == n_dt
                cb = colorbar(ax);
                ylabel(cb, '$\mathrm{signal\ RMSE\ std}$', 'FontSize', axis_label_font_size, 'Interpreter', 'latex');
            end
        end

        title(tl, sprintf('STD | %s | $b_{\\max}=%g\\,\\mathrm{s/mm^2}$ | SNR=%s | $N=%d$', ...
            local_mode_label(mode_name, lambda_unregularized, lambda_regularized, lambda_two_stage), ...
            max(b_smm2), snr_label, N_SNR), ...
            'FontSize', figure_title_font_size, 'FontWeight', 'bold', 'Interpreter', 'latex');

        if do_save
            png_fn = fullfile(output_dir, sprintf('demo_vasco16_fit_evaluation_std_%s_%s_%s.png', mode_name, snr_tag, n_snr_tag));
            saveas(fig, png_fn);
            fprintf('Saved figure: %s\n', png_fn);
        end
    end
end

%% Signal vs b plots for selected cases

fc = xps.s_ind == fc_series_id;
nc = xps.s_ind == nc_series_id;
b_fc_data = xps.b(fc) * 1e-6;
b_nc_data = xps.b(nc) * 1e-6;
bmax = max(xps.b(:)) * 1.05;
nfit = 256;

xps_fc_plot = struct;
xps_fc_plot.b = linspace(eps, bmax, nfit)';
xps_fc_plot.alpha2 = zeros(nfit, 1);
xps_fc_plot.s_ind = fc_series_id * ones(nfit, 1);

xps_nc_plot = struct;
xps_nc_plot.b = linspace(eps, bmax, nfit)';
xps_nc_plot.alpha2 = alpha2_over_b_nc * xps_nc_plot.b;
xps_nc_plot.s_ind = nc_series_id * ones(nfit, 1);

for i_case = 1:numel(signal_demo_vd_um_per_ms)
    [~, i_dt_sel] = min(abs(d_tissue_um2_per_ms - signal_demo_d_tissue_um2_per_ms(i_case)));
    [~, i_f_sel] = min(abs(f_blood - signal_demo_fb(i_case)));
    [~, i_vd_sel] = min(abs(vd_um_per_ms - signal_demo_vd_um_per_ms(i_case)));

    data_fc_all = squeeze(signal_obs_all(fc, i_f_sel, i_vd_sel, i_dt_sel, :));
    data_nc_all = squeeze(signal_obs_all(nc, i_f_sel, i_vd_sel, i_dt_sel, :));
    if N_SNR == 1
        data_fc_all = data_fc_all(:);
        data_nc_all = data_nc_all(:);
    end
    i_rep_plot = min(signal_realization_to_plot, N_SNR);

    for i_mode = 1:n_mode
        fig_index = signal_figure_number_start + (i_case - 1) * n_mode + (i_mode - 1);
        fig = figure(fig_index); clf(fig);
        set(fig, 'Color', 'w', 'Position', signal_figure_position);
        ax = axes('Parent', fig);
        hold(ax, 'on');

        if N_SNR > 1
            plot(ax, repmat(b_fc_data(:), N_SNR, 1), data_fc_all(:), 'o', ...
                'Color', [1 0 0], 'MarkerFaceColor', 'none', 'MarkerSize', 3, ...
                'LineWidth', 0.5, 'HandleVisibility', 'off');
            plot(ax, repmat(b_nc_data(:), N_SNR, 1), data_nc_all(:), 'o', ...
                'Color', [0 0 1], 'MarkerFaceColor', 'none', 'MarkerSize', 3, ...
                'LineWidth', 0.5, 'HandleVisibility', 'off');
            data_fc = data_fc_all(:, i_rep_plot);
            data_nc = data_nc_all(:, i_rep_plot);
        else
            data_fc = data_fc_all(:);
            data_nc = data_nc_all(:);
        end

        plot(ax, b_fc_data, data_fc, 'ro', 'MarkerFaceColor', 'r', ...
            'MarkerSize', 6, 'LineWidth', 1.2, 'DisplayName', 'FC data');
        plot(ax, b_nc_data, data_nc, 'bo', 'MarkerFaceColor', 'w', ...
            'MarkerSize', 6, 'LineWidth', 1.2, 'DisplayName', 'NC data');

        m_fit_here_all = squeeze(m_fit_all(:, i_f_sel, i_vd_sel, i_dt_sel, i_mode, :));
        if N_SNR == 1
            m_fit_here_all = m_fit_here_all(:);
        end
        m_fit_mean = mean(m_fit_here_all, 2);
        vd_fit_here = sqrt(m_fit_mean(2)) * 1e3;
        fb_fit_here = m_fit_mean(3);
        vd_err_pct = mean(squeeze(vd_pct(i_f_sel, i_vd_sel, i_dt_sel, i_mode, :)));
        fb_err_pct = mean(squeeze(fb_pct(i_f_sel, i_vd_sel, i_dt_sel, i_mode, :)));
        s_fc_fit = vasco16_1d_fit2data(m_fit_mean(:)', xps_fc_plot);
        s_nc_fit = vasco16_1d_fit2data(m_fit_mean(:)', xps_nc_plot);

        plot(ax, xps_fc_plot.b / 1e6, s_fc_fit, 'r-', 'LineWidth', 2.0, ...
            'DisplayName', 'FC fit');
        plot(ax, xps_nc_plot.b / 1e6, s_nc_fit, 'b-', 'LineWidth', 2.0, ...
            'DisplayName', 'NC fit');

        if strcmp(fit_cases{i_mode}, 'two_stage')
            prefit_fc = squeeze(mean(signal_prefit_all(fc, i_f_sel, i_vd_sel, i_dt_sel, i_mode, :), 6, 'omitnan'));
            if any(isfinite(prefit_fc))
                plot(ax, b_fc_data, prefit_fc, 'g:', 'LineWidth', 2.0, ...
                    'DisplayName', 'FC tissue prefit');
            end
        end

        grid(ax, 'off');
        box(ax, 'off');
        set(ax, 'TickDir', 'out');
        xlabel(ax, '$b\ [\mathrm{s/mm^2}]$', 'FontSize', axis_label_font_size, 'Interpreter', 'latex');
        ylabel(ax, '$\mathrm{signal}$', 'FontSize', axis_label_font_size, 'Interpreter', 'latex');
        title(ax, sprintf(['%s\n' ...
            '$D_t=%.2f\\,\\mu\\mathrm{m}^2/\\mathrm{ms}$, SNR=%s, $N=%d$\n' ...
            '$v_d=%.3f\\,(%.1f\\%%)$, $f_b=%.3f\\,(%.1f\\%%)$'], ...
            local_mode_label(fit_cases{i_mode}, lambda_unregularized, lambda_regularized, lambda_two_stage), ...
            d_tissue_um2_per_ms(i_dt_sel), snr_label, N_SNR, ...
            vd_fit_here, vd_err_pct, fb_fit_here, fb_err_pct), ...
            'FontSize', figure_title_font_size, 'FontWeight', 'bold', 'Interpreter', 'latex');
        legend(ax, 'Location', 'best', 'Box', 'off');

        if do_save
            png_fn = fullfile(output_dir, sprintf('demo_vasco16_signal_fit_case_%02d_%s_%s_%s.png', ...
                i_case, fit_cases{i_mode}, snr_tag, n_snr_tag));
            saveas(fig, png_fn);
            fprintf('Saved figure: %s\n', png_fn);
        end
    end
end

if do_save
    fid = fopen(summary_txt_fn, 'w');
    assert(fid ~= -1, 'Could not open summary file for writing: %s', summary_txt_fn);
    for i_line = 1:numel(summary_lines)
        fprintf(fid, '%s\n', summary_lines{i_line});
    end
    fclose(fid);
    fprintf('Saved summary: %s\n', summary_txt_fn);

    if do_generate
        % Full raw evaluation arrays for reload/replot without recomputing fits.
        save(save_fn, ...
            'fit_cases', 'b_smm2', 'vd_um_per_ms', 'f_blood', 'd_tissue_um2_per_ms', ...
            'vd_pct', 'fb_pct', 'rmse', 'dt_fit_um2_per_ms', ...
            'signal_true_all', 'signal_obs_all', 'signal_fit_all', 'signal_prefit_all', 'm_fit_all', 'xps', ...
            'lambda_unregularized', 'lambda_regularized', 'lambda_two_stage', ...
            'reg_vd_lb', 'reg_vd_ub', 'reg_delta_vd', ...
            'fit_guess', 'fit_lb', 'fit_ub', ...
            'dt_high_b_threshold_smm2', 'dt_two_stage_rel_window', ...
            'snr', 'N_SNR', 'signal_demo_d_tissue_um2_per_ms', 'signal_demo_fb', 'signal_demo_vd_um_per_ms');
        fprintf('Saved results: %s\n', save_fn);
    end
end

%% Local helpers

function alpha2_over_b_nc = local_resolve_fc_ratio(bipolar_xps_fn, nc_series_id)
x = load(bipolar_xps_fn);
xps_ref = x.xps;
b = double(xps_ref.b(:));
alpha2 = double(xps_ref.alpha2(:));
s_ind = double(xps_ref.s_ind(:));
mask = s_ind == nc_series_id & b > 0;

if ~any(mask)
    error('Could not derive NC alpha2/b ratio from reference xps.');
end

alpha2_over_b_nc = median(alpha2(mask) ./ b(mask));
end

function xps = local_make_demo_xps(b_smm2, alpha2_over_b_nc, fc_series_id, nc_series_id)
b_si = b_smm2(:) * 1e6;
n_b = numel(b_si);

xps = struct;
xps.n = 2 * n_b;
xps.b = [b_si; b_si];
xps.alpha2 = [zeros(n_b, 1); alpha2_over_b_nc * b_si];
xps.s_ind = [zeros(n_b, 1) + fc_series_id; zeros(n_b, 1) + nc_series_id];
xps.is_fc = xps.s_ind == fc_series_id;
end

function [dt_est_mm2_per_s, a_est] = local_estimate_dtissue_fc_high_b(signal, xps, b_thresh_smm2, fc_series_id)
b_smm2_local = xps.b(:) / 1e6;
idx = xps.s_ind(:) == fc_series_id & b_smm2_local >= b_thresh_smm2;

if nnz(idx) < 2
    error('Cannot estimate Dt: too few high-b FC points.');
end

S = signal(idx);
b = b_smm2_local(idx);

if any(S <= 0)
    error('Cannot estimate Dt: nonpositive FC high-b signal.');
end

X = [ones(numel(b), 1), -b(:)];
p = X \ log(S(:));
dt_est_mm2_per_s = p(2);
a_est = exp(p(1));
end

function [signal_true, signal_obs_vox, signal_fit_vox, signal_prefit_vox, m_fit_vox, vd_pct_vox, fb_pct_vox, rmse_vox, dt_fit_vox] = ...
    local_fit_one_voxel(i_vox, xps, n_dt, n_f, n_vd, d_tissue_um2_per_ms, f_blood, vd_um_per_ms, s0, w, d_blood_um2_per_ms, snr, N_SNR, n_mode, fit_cases, fit_guess, fit_lb, fit_ub, reg_vd_lb, reg_vd_ub, reg_delta_vd, lambda_unregularized, lambda_regularized, lambda_two_stage, dt_high_b_threshold_smm2, dt_two_stage_rel_window, fc_series_id)
[i_dt, i_f, i_vd] = ind2sub([n_dt, n_f, n_vd], i_vox);

d_tissue_true_um2_per_ms = d_tissue_um2_per_ms(i_dt);
f_true = f_blood(i_f);
vd_true_um_per_ms = vd_um_per_ms(i_vd);

m_true = [ ...
    s0, ...
    (vd_true_um_per_ms * 1e-3)^2, ...
    f_true, ...
    d_blood_um2_per_ms * 1e-9, ...
    d_tissue_true_um2_per_ms * 1e-9, ...
    w];

signal_true = vasco16_1d_fit2data(m_true, xps);

if isinf(snr)
    noise_sigma = 0;
else
    noise_sigma = max(signal_true) / snr;
end

n_signal = xps.n;
fc_mask = xps.s_ind == fc_series_id;
b_fc_si = xps.b(fc_mask);

signal_obs_vox = zeros(n_signal, N_SNR);
signal_fit_vox = zeros(n_signal, n_mode, N_SNR);
signal_prefit_vox = nan(n_signal, n_mode, N_SNR);
m_fit_vox = zeros(6, n_mode, N_SNR);
vd_pct_vox = zeros(n_mode, N_SNR);
fb_pct_vox = zeros(n_mode, N_SNR);
rmse_vox = zeros(n_mode, N_SNR);
dt_fit_vox = zeros(n_mode, N_SNR);

for i_rep = 1:N_SNR
    signal_obs = signal_true + noise_sigma * randn(size(signal_true));

    if any(signal_obs <= 0)
        error('Synthetic signal became nonpositive.');
    end

    signal_obs_vox(:, i_rep) = signal_obs;

    for i_mode = 1:n_mode
        mode_name = fit_cases{i_mode};

        opt = vasco16_opt(struct);
        opt.vasco16.do_plot = 0;
        opt.vasco16.dblood = d_blood_um2_per_ms * 1e-9;
        opt.vasco16.fit_guess = fit_guess;
        opt.vasco16.fit_lb = fit_lb;
        opt.vasco16.fit_ub = fit_ub;
        opt.vasco16.reg_vd_lb = reg_vd_lb;
        opt.vasco16.reg_vd_ub = reg_vd_ub;
        opt.vasco16.reg_delta_vd = reg_delta_vd;

        switch mode_name
            case 'unregularized'
                opt.vasco16.reg_lambda = lambda_unregularized;

            case 'regularized'
                opt.vasco16.reg_lambda = lambda_regularized;

            case 'two_stage'
                opt.vasco16.reg_lambda = lambda_two_stage;

                [dt_est_mm2_per_s, a_est] = local_estimate_dtissue_fc_high_b( ...
                    signal_obs, xps, dt_high_b_threshold_smm2, fc_series_id);

                dt_est_si = dt_est_mm2_per_s * 1e-6;
                dt_lb = max(fit_lb(2), dt_est_si * (1 - dt_two_stage_rel_window));
                dt_ub = min(fit_ub(2), dt_est_si * (1 + dt_two_stage_rel_window));

                opt.vasco16.fit_lb(2) = dt_lb;
                opt.vasco16.fit_ub(2) = dt_ub;
                opt.vasco16.fit_guess(2) = min(max(dt_est_si, dt_lb), dt_ub);

                signal_prefit_vox(fc_mask, i_mode, i_rep) = a_est * exp(-b_fc_si * dt_est_si);

            otherwise
                error('Unknown mode: %s', mode_name);
        end

        m_fit = vasco16_1d_data2fit(signal_obs, xps, opt);
        signal_fit = vasco16_1d_fit2data(m_fit, xps);

        signal_fit_vox(:, i_mode, i_rep) = signal_fit;
        m_fit_vox(:, i_mode, i_rep) = m_fit(:);

        vd_fit_here = sqrt(m_fit(2)) * 1e3;
        vd_pct_vox(i_mode, i_rep) = 100 * (vd_fit_here / vd_true_um_per_ms - 1);
        fb_pct_vox(i_mode, i_rep) = 100 * (m_fit(3) / f_true - 1);
        rmse_vox(i_mode, i_rep) = sqrt(mean((signal_fit - signal_obs).^2));
        dt_fit_vox(i_mode, i_rep) = m_fit(5) * 1e9;
    end
end
end

function clim = local_pick_row_clim(data, user_clim, symmetric)
if ~isempty(user_clim)
    clim = user_clim;
    return;
end

vals = data(isfinite(data));
if isempty(vals)
    clim = [0 1];
    return;
end

if symmetric
    vmax = max(abs(vals));
    if vmax == 0
        vmax = 1;
    end
    clim = [-vmax, vmax];
else
    clim = [min(vals), max(vals)];
    if clim(1) == clim(2)
        clim = clim + [-1, 1] * max(abs(clim(1)), 1) * 0.1;
    end
end
end

function s = local_mode_label(mode_name, lambda_unregularized, lambda_regularized, lambda_two_stage)
switch mode_name
    case 'unregularized'
        s = sprintf('Unregularized, $\\lambda = %.3g$', lambda_unregularized);
    case 'regularized'
        s = sprintf('Regularized, $\\lambda = %.3g$', lambda_regularized);
    case 'two_stage'
        s = sprintf('Two-stage $D_t$ estimate, $\\lambda = %.3g$', lambda_two_stage);
    otherwise
        s = mode_name;
end
end

function [stats, lines] = local_collect_summary(mode_name, mode_vd_bias, mode_fb_bias, mode_rmse_mean, mode_vd_all, mode_fb_all, mode_rmse_all, vd_um_per_ms, f_blood, d_tissue_um2_per_ms, lambda_unregularized, lambda_regularized, lambda_two_stage)
stats = struct('mode_name', mode_name, 'lambda', NaN);
switch mode_name
    case 'unregularized'
        stats.lambda = lambda_unregularized;
    case 'regularized'
        stats.lambda = lambda_regularized;
    case 'two_stage'
        stats.lambda = lambda_two_stage;
    otherwise
        stats.lambda = NaN;
end

stats.vd_bias_mean = mean(mode_vd_bias(:));
stats.vd_bias_min = min(mode_vd_bias(:));
stats.vd_bias_p10 = prctile(mode_vd_bias(:), 10);
stats.vd_bias_median = median(mode_vd_bias(:));
stats.vd_bias_p90 = prctile(mode_vd_bias(:), 90);
stats.vd_bias_max = max(mode_vd_bias(:));
stats.fb_bias_mean = mean(mode_fb_bias(:));
stats.fb_bias_min = min(mode_fb_bias(:));
stats.fb_bias_p10 = prctile(mode_fb_bias(:), 10);
stats.fb_bias_median = median(mode_fb_bias(:));
stats.fb_bias_p90 = prctile(mode_fb_bias(:), 90);
stats.fb_bias_max = max(mode_fb_bias(:));
stats.rmse_mean = mean(mode_rmse_mean(:));
stats.rmse_min = min(mode_rmse_mean(:));
stats.rmse_p10 = prctile(mode_rmse_mean(:), 10);
stats.rmse_median = median(mode_rmse_mean(:));
stats.rmse_p90 = prctile(mode_rmse_mean(:), 90);
stats.rmse_max = max(mode_rmse_mean(:));

if size(mode_vd_all, 5) > 1
    mode_vd_std = std(mode_vd_all, 0, 5);
    mode_fb_std = std(mode_fb_all, 0, 5);
    mode_rmse_std = std(mode_rmse_all, 0, 5);
    stats.vd_std_mean = mean(mode_vd_std(:));
    stats.vd_std_min = min(mode_vd_std(:));
    stats.vd_std_p10 = prctile(mode_vd_std(:), 10);
    stats.vd_std_median = median(mode_vd_std(:));
    stats.vd_std_p90 = prctile(mode_vd_std(:), 90);
    stats.vd_std_max = max(mode_vd_std(:));
    stats.fb_std_mean = mean(mode_fb_std(:));
    stats.fb_std_min = min(mode_fb_std(:));
    stats.fb_std_p10 = prctile(mode_fb_std(:), 10);
    stats.fb_std_median = median(mode_fb_std(:));
    stats.fb_std_p90 = prctile(mode_fb_std(:), 90);
    stats.fb_std_max = max(mode_fb_std(:));
    stats.rmse_std_mean = mean(mode_rmse_std(:));
    stats.rmse_std_min = min(mode_rmse_std(:));
    stats.rmse_std_p10 = prctile(mode_rmse_std(:), 10);
    stats.rmse_std_median = median(mode_rmse_std(:));
    stats.rmse_std_p90 = prctile(mode_rmse_std(:), 90);
    stats.rmse_std_max = max(mode_rmse_std(:));
else
    stats.vd_std_mean = NaN;
    stats.fb_std_mean = NaN;
    stats.rmse_std_mean = NaN;
end

[~, i_vd_center] = min(abs(vd_um_per_ms - mean(vd_um_per_ms([1 end]))));
[~, i_fb_center] = min(abs(f_blood - mean(f_blood([1 end]))));
[~, i_dt_center] = min(abs(d_tissue_um2_per_ms - mean(d_tissue_um2_per_ms([1 end]))));

mode_vd_std_map = std(mode_vd_all, 0, 5);
mode_fb_std_map = std(mode_fb_all, 0, 5);

stats.center_vd_bias = mean(mode_vd_bias(i_fb_center, i_vd_center, :), 3);
stats.center_fb_bias = mean(mode_fb_bias(i_fb_center, i_vd_center, :), 3);
stats.center_vd_std = mean(mode_vd_std_map(i_fb_center, i_vd_center, :), 3);
stats.center_fb_std = mean(mode_fb_std_map(i_fb_center, i_vd_center, :), 3);

lines = {};
lines{end+1} = sprintf('%s summary', mode_name);
lines{end+1} = sprintf('  lambda: %.6g', stats.lambda);
lines{end+1} = sprintf('  vd bias [%%]: mean: %.1f | median: %.1f | P10: %.1f | P90: %.1f | min: %.1f | max: %.1f', ...
    stats.vd_bias_mean, stats.vd_bias_median, stats.vd_bias_p10, stats.vd_bias_p90, stats.vd_bias_min, stats.vd_bias_max);
lines{end+1} = sprintf('  fb bias [%%]: mean: %.1f | median: %.1f | P10: %.1f | P90: %.1f | min: %.1f | max: %.1f', ...
    stats.fb_bias_mean, stats.fb_bias_median, stats.fb_bias_p10, stats.fb_bias_p90, stats.fb_bias_min, stats.fb_bias_max);
if size(mode_vd_all, 5) > 1
    lines{end+1} = sprintf('  vd std [%%]: mean: %.1f | median: %.1f | P10: %.1f | P90: %.1f | min: %.1f | max: %.1f', ...
        stats.vd_std_mean, stats.vd_std_median, stats.vd_std_p10, stats.vd_std_p90, stats.vd_std_min, stats.vd_std_max);
    lines{end+1} = sprintf('  fb std [%%]: mean: %.1f | median: %.1f | P10: %.1f | P90: %.1f | min: %.1f | max: %.1f', ...
        stats.fb_std_mean, stats.fb_std_median, stats.fb_std_p10, stats.fb_std_p90, stats.fb_std_min, stats.fb_std_max);
    lines{end+1} = sprintf('  RMSE std: mean: %.6f | median: %.6f | P10: %.6f | P90: %.6f | min: %.6f | max: %.6f', ...
        stats.rmse_std_mean, stats.rmse_std_median, stats.rmse_std_p10, stats.rmse_std_p90, stats.rmse_std_min, stats.rmse_std_max);
end
lines{end+1} = sprintf('  signal RMSE: mean: %.6f | median: %.6f | P10: %.6f | P90: %.6f | min: %.6f | max: %.6f', ...
    stats.rmse_mean, stats.rmse_median, stats.rmse_p10, stats.rmse_p90, stats.rmse_min, stats.rmse_max);
lines{end+1} = sprintf('  center (vd=%.3g, fb=%.3g, Dt=%.3g): vd: %.1f (%.1f) | fb: %.1f (%.1f) [bias(std) %%]', ...
    vd_um_per_ms(i_vd_center), f_blood(i_fb_center), d_tissue_um2_per_ms(i_dt_center), ...
    stats.center_vd_bias, stats.center_vd_std, stats.center_fb_bias, stats.center_fb_std);
end

function local_print_summary(stats)
fprintf('%s summary\n', stats.mode_name);
fprintf('  lambda               %.6g\n', stats.lambda);
fprintf('  vd bias [%%]         mean: %.1f | median: %.1f | P10: %.1f | P90: %.1f | min: %.1f | max: %.1f\n', ...
    stats.vd_bias_mean, stats.vd_bias_median, stats.vd_bias_p10, stats.vd_bias_p90, stats.vd_bias_min, stats.vd_bias_max);
fprintf('  fb bias [%%]         mean: %.1f | median: %.1f | P10: %.1f | P90: %.1f | min: %.1f | max: %.1f\n', ...
    stats.fb_bias_mean, stats.fb_bias_median, stats.fb_bias_p10, stats.fb_bias_p90, stats.fb_bias_min, stats.fb_bias_max);
if ~isnan(stats.vd_std_mean)
    fprintf('  vd std [%%]          mean: %.1f | median: %.1f | P10: %.1f | P90: %.1f | min: %.1f | max: %.1f\n', ...
        stats.vd_std_mean, stats.vd_std_median, stats.vd_std_p10, stats.vd_std_p90, stats.vd_std_min, stats.vd_std_max);
    fprintf('  fb std [%%]          mean: %.1f | median: %.1f | P10: %.1f | P90: %.1f | min: %.1f | max: %.1f\n', ...
        stats.fb_std_mean, stats.fb_std_median, stats.fb_std_p10, stats.fb_std_p90, stats.fb_std_min, stats.fb_std_max);
    fprintf('  RMSE std             mean: %.6f | median: %.6f | P10: %.6f | P90: %.6f | min: %.6f | max: %.6f\n', ...
        stats.rmse_std_mean, stats.rmse_std_median, stats.rmse_std_p10, stats.rmse_std_p90, stats.rmse_std_min, stats.rmse_std_max);
end
fprintf('  signal RMSE          mean: %.6f | median: %.6f | P10: %.6f | P90: %.6f | min: %.6f | max: %.6f\n', ...
    stats.rmse_mean, stats.rmse_median, stats.rmse_p10, stats.rmse_p90, stats.rmse_min, stats.rmse_max);
fprintf('  center bias(std) [%%] vd: %.1f (%.1f) | fb: %.1f (%.1f)\n', ...
    stats.center_vd_bias, stats.center_vd_std, stats.center_fb_bias, stats.center_fb_std);
fprintf('\n');
end
