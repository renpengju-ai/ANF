function plot_preprocessing_flow(datasetName)
% 绘制数据预处理流程图（原始 -> 清洗 -> 标准化）
% 修复版：解决了老版本 MATLAB 无法识别 t.FontName 的报错
%
% 调用示例：
%   plot_preprocessing_flow('HSI_Index');
%   plot_preprocessing_flow('SSE_Index');
%   plot_preprocessing_flow('SandP_Index');

    if nargin < 1
        datasetName = 'SandP_Index';   % Default S&P 500 Index
    end

    %% 0. Font setting
    fontCN = 'Times New Roman';
    
    %% 1. Load dataset from Benchmarks
    dataFile = fullfile('Benchmarks', [datasetName '.mat']);
    
    % 文件检查
    if ~isfile(dataFile)
        error('Data file not found: %s', dataFile);
    end
    
    S = load(dataFile);
    if isfield(S, 'data')
        x = S.data(:, 1);
    else
        fns = fieldnames(S);
        x = S.(fns{1});
        if size(x, 2) > 1
            x = x(:, 1);
        end
    end
    x = x(:);
    N = numel(x);

    %% 2. Construct date axis
    startDate = datetime(2010, 1, 1);
    dates = startDate + caldays(0:N-1)';

    %% 3. Data preprocessing
    % 3.1 Original
    original = x;

    % 3.2 Cleaned
    cleaned = fillmissing(original, 'linear');
    win  = 5;
    med  = movmedian(cleaned, win, 'omitnan');
    diffVal = cleaned - med;
    thr  = 3 * std(diffVal, 'omitnan');
    mask = abs(diffVal) > thr;
    cleaned(mask) = med(mask);

    % 3.3 Normalized
    minVal = min(cleaned);
    maxVal = max(cleaned);
    if maxVal > minVal
        normalized = (cleaned - minVal) ./ (maxVal - minVal);
    else
        normalized = zeros(size(cleaned));
    end

    %% 4. Color setting
    colorOriginal   = [0.00 0.45 0.74];
    colorCleaned    = [0.13 0.55 0.13];
    colorNormalized = [0.85 0.33 0.10];

    %% 5. Dataset English name
    switch datasetName
        case 'HSI_Index'
            seriesName = 'Hang Seng Index (HSI)';
        case 'SSE_Index'
            seriesName = 'Shanghai Composite Index (SSE)';
        case 'SandP_Index'
            seriesName = 'S&P 500 Index (S&P 500)';
        otherwise
            seriesName = datasetName;
    end

    %% 6. Single figure + three subplots
    fig = figure('Color', 'w', 'Position', [80 80 1100 600]);
    
    % 【修改点】：不再设置 t.FontName，避免报错
    t = tiledlayout(3, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
    
    % ---- Subplot 1: Original ----
    ax1 = nexttile;
    plot(dates, original, 'Color', colorOriginal, 'LineWidth', 1.2);
    grid on; box on;
    ylabel('Index Value');
    title(sprintf('Original Data (%s)', seriesName), 'FontSize', 11);
    xlim([dates(1) dates(end)]);

    % ---- Subplot 2: Cleaned ----
    ax2 = nexttile;
    plot(dates, cleaned, 'Color', colorCleaned, 'LineWidth', 1.2);
    grid on; box on;
    ylabel('Index Value');
    title('Cleaned Data (missing values and outliers handled)', 'FontSize', 11);
    xlim([dates(1) dates(end)]);

    % ---- Subplot 3: Normalized ----
    ax3 = nexttile;
    plot(dates, normalized, 'Color', colorNormalized, 'LineWidth', 1.2);
    grid on; box on;
    ylabel('Normalized Value');
    xlabel('Date');
    title('Normalized Data (Min-Max scaled to [0, 1])', 'FontSize', 11);
    xlim([dates(1) dates(end)]);
    
    % 联动缩放
    linkaxes([ax1, ax2, ax3], 'x');

    %% 7. Uniform x-axis & Font Application
    yearsAll  = year(dates);
    uniqYears = unique(yearsAll);
    janIdx = arrayfun(@(y) find(year(dates)==y & month(dates)==1, 1, 'first'), uniqYears);
    
    axAll = [ax1, ax2, ax3]; 
    
    monthNames = {'Jan','Feb','Mar','Apr','May','Jun', ...
                  'Jul','Aug','Sep','Oct','Nov','Dec'};
    bottomLabels = cell(numel(janIdx),1);
    for i = 1:numel(janIdx)
        d = dates(janIdx(i));
        bottomLabels{i} = sprintf('%s %d', monthNames{month(d)}, year(d));
    end

    % 统一设置 Tick 和字体
    for k = 1:numel(axAll)
        axAll(k).XTick = dates(janIdx);
        axAll(k).XTickLabelRotation = 0;
        axAll(k).XTickLabel = bottomLabels;
        
        % 【修改点】：在这里统一设置字体，对旧版本 MATLAB 更兼容
        axAll(k).FontName = fontCN;
        set(axAll(k).Title, 'FontName', fontCN); % 强制标题也使用该字体
        set(axAll(k).XLabel, 'FontName', fontCN);
        set(axAll(k).YLabel, 'FontName', fontCN);
    end

    %% 8. Export
    outName = sprintf('%s_Preprocessing_Flow.png', datasetName);
    exportgraphics(fig, outName, 'Resolution', 300);
    fprintf('Preprocessing flow figure exported as: %s\n', outName);
end