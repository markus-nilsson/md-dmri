function m = mplot_s_vs_b_by_b_delta(S, xps, fun_data2fit, fun_fit2data, opt, h, h2, ind)
% function mplot_s_vs_b_by_b_delta(S, xps, fun_data2fit, fun_fit2data, opt, h, h2)

if (nargin < 3), fun_data2fit = []; end
if (nargin < 4), fun_fit2data = []; end
if (nargin < 5), opt = []; end
if (nargin < 6), h = gca; end
if (nargin < 7), h2 = []; end
if (nargin < 8), ind = []; end

% Hack to make things work again
if (isa(opt, 'function_handle'))
    opt = opt();
end

% init
if (isa(opt, 'function_handle')), opt = opt(); end
opt = mplot_opt(opt);

data_marker = 'o';

if (isempty(fun_data2fit) || isempty(fun_fit2data))
    data_marker = 'o-';
end

% adapt xps
xps = msf_ensure_field(xps, 'b_eta', zeros(size(xps.b_delta)));


% This is for powder averaged data... so make it powder averaged if needed
xps_pa = mdm_xps_pa(msf_rmfield(xps, 'c_volume'));

if (xps_pa.n ~= xps.n)
    if (isfield(xps,'c_volume'))
        c_volume = xps.c_volume;
        xps = rmfield(xps, 'c_volume');
    else
        c_volume = [];
    end
    
    [S,xps] = mdm_powder_average_1d(S, xps);
    
    xps.c_volume = c_volume;
end

% fit function
if (nargin < 8)
    ind = ones(size(S)) == 1;
end

if (~isempty(fun_data2fit))
    m = fun_data2fit(S(ind), mdm_xps_subsample(xps, ind), opt);
else
    m = [];
end



% find unique b_delta
b_delta_input = round(xps.b_delta * 100) / 100;

[b_delta_uni,~] = unique(b_delta_input);

b_delta_uni = sort(b_delta_uni);

if (numel(b_delta_uni) == 1)
    cmap = [0 0 0];
else
    cmap = 0.7 * hsv(numel(b_delta_uni) + 2);
end

% Allow 'hold on' to be used
try
    if (~strcmp(get(h, 'nextplot'), 'add'))
        error('jump out');
    end
catch
    cla(h);
    hold(h, 'off');
end


% Plot for legend
hold(h, 'off');
for c = 1:numel(b_delta_uni)
    col = mplot_b_shape_to_col(b_delta_uni(c));    
    semilogy(h, -1,2,'-', 'color', col, 'linewidth', 2); hold(h,'on');
end

for c = 1:numel(b_delta_uni)
    
    ind2 = b_delta_input == b_delta_uni(c);
    
    ind3 = ind2 & (~ind);
    
    col = mplot_b_shape_to_col(b_delta_uni(c));

    
    % Construct a fitted signal
    clear xps2;
    try
        xps2.n = 64;
        xps2.b = linspace(eps, max(xps.b(ind2)) * 1.1, xps2.n)';
        
        z = zeros(size(xps2.b));
        
        xps2.b_delta = z + mean(xps.b_delta(ind2));
        xps2.b_eta   = z + mean(xps.b_eta(ind2));
        
        if (isfield(xps, 's_ind'))
            tmp = xps.s_ind(ind2);
            
            if (numel(unique(tmp)) ~= 1)
                error('Cannot figure out which s_ind to use');
            end
            
            xps2.s_ind = z + tmp(1); % all should be equal
        end
    catch me
        1;
    end
    
    if (isempty(m))
        S_fit = zeros(xps2.n,1);
        sc = max(S(:));
    else
        try
            
            S_fit = fun_fit2data(m, xps2);
            
            % This now allows for separate scaling of each series
            sc = S_fit(1);
        catch
            xps2 = mdm_xps_subsample(xps, ind2);
            S_fit = fun_fit2data(m, xps2);
            
            % Scale by m(1) assuming it represents S0
            sc = m(1);
        end
    end
    
    semilogy(h, xps.b(ind2) * 1e-9, S(ind2) / sc, data_marker, 'color', col, ...
        'markersize', 5, 'markerfacecolor', col, 'linewidth', 2);
    
    hold(h, 'on');
    
    semilogy(h, xps.b(ind3) * 1e-9, S(ind3) / sc, 'x', 'color', col, ...
        'markersize', 10, 'markerfacecolor', col);
    
    semilogy(h, xps2.b * 1e-9, S_fit / sc, '-', 'color', col, 'linewidth', 2);
end

axis(h, 'on');


xlim(h, [0 max(xps2.b) * 1.1e-9]);
ylim(h, [min(0.1, max(0.0001, 10^floor(log10(min(S(S(:) > 0) / sc))))) 1.1]);

xlabel(h, 'b [ms/um^2]', 'fontsize', opt.mplot.fs);
ylabel(h, 'Signal', 'fontsize', opt.mplot.fs);



% show legend

l_str = cell(1,numel(b_delta_uni));
for c = 1:numel(b_delta_uni)
    col = mplot_b_shape_to_col(b_delta_uni(c));    
    plot(h,10,10,'-', 'color', col, 'linewidth', 2);
    hold(h, 'on');
    l_str{c} = ['b_\Delta = ' num2str(b_delta_uni(c))];
end
legend(h, l_str, 'location', 'northeast');
legend(h, 'boxoff');



set(h,...
    'TickDir','out', ...
    'TickLength',.02*[1 1], ...
    'FontSize',opt.mplot.fs, ...
    'LineWidth',opt.mplot.lw, ...
    'Box','off')



% show dtd plots: need to make some sloppy assumptions to make it work
name = char(fun_data2fit);
dt_1x6 = []; w = [];
switch (name(1:(strfind(name, '1d_data2fit')-2)))
    
    case 'dtd_codivide'
        
        mdt = m(4);
        md_fw = m(5);
        
        dt_1x6 = cat(1, ...
            tm_1x3_to_1x6(md_fw, md_fw, [1 0 0]), ...
            tm_1x3_to_1x6(mdt * 2.8, 0.1 * mdt, [1 0 0]), ...
            tm_1x3_to_1x6(mdt, mdt, [1 0 0]));
        
        w = [m(3) m(2) 1 - m(2) - m(3)];
        
    case 'dtd_ndi'
        
        v_int = m(2);
        v_csf = m(3);
        ad_ic = m(4);
        md_fw = m(5);
        
        md_ext = (1 - 2/3 * v_int) * ad_ic;

        dt_1x6 = cat(1, ...
            tm_1x3_to_1x6(md_fw, md_fw, [1 0 0]), ...
            tm_1x3_to_1x6(ad_ic, 0.05e-9, [1 0 0]), ...
            tm_1x3_to_1x6(md_ext, md_ext, [1 0 0]));
        
        w = [v_csf [v_int 1 - v_int] * (1 - v_csf)];
        
end

if (~isempty(w))
    opt.mplot.dtd_col_mode = 0;
    mplot_dtd(dt_1x6, w, 0.05e-9, 4.5e-9, h2, opt);
else
    axis(h2, 'off');
end

