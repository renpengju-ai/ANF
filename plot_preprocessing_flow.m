function plot_preprocessing_flow(datasetName)
% 绘制数据预处理流程图（原始 -> 清洗 -> 标准化）
% 可用于 Benchmarks 下的 HSI_Index / SSE_Index / SandP_Index
%
% 调用示例：
%   plot_preprocessing_flow('HSI_Index');
%   plot_preprocessing_flow('SSE_Index');
%   plot_preprocessing_flow('SandP_Index');

    if nargin < 1
        datasetName = 'SSE_Index';   % Default S&P 500 Index
    end

    %% 0. Font setting: Use Times New Roman
    fontCN = 'Times New Roman';
    set(0, 'defaultAxesFontName',  fontCN);
    set(0, 'defaultTextFontName',  fontCN);

    %% 1. Load dataset from Benchmarks
    dataFile = fullfile('Benchmarks', [datasetName '.mat']);
    S = load(dataFile);

    % Default use data(:,1), otherwise take the first column of the first variable
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

    %% 2. Construct date axis (示意：从 2010-01-01 起，按日递增)
    startDate = datetime(2010, 1, 1);
    dates = startDate + caldays(0:N-1)';

    %% 3. Data preprocessing
    % 3.1 Original data
    original = x;

    % 3.2 Cleaned data: interpolation + simple outlier removal
    cleaned = fillmissing(original, 'linear');          % Fill NaN
    win  = 5;
    med  = movmedian(cleaned, win, 'omitnan');
    diffVal = cleaned - med;
    thr  = 3 * std(diffVal, 'omitnan');                 % 3σ rule
    mask = abs(diffVal) > thr;
    cleaned(mask) = med(mask);

    % 3.3 Normalization (Min–Max to [0,1])
    minVal = min(cleaned);
    maxVal = max(cleaned);
    if maxVal > minVal
        normalized = (cleaned - minVal) ./ (maxVal - minVal);
    else
        normalized = zeros(size(cleaned));
    end

    %% 4. Color setting
    colorOriginal   = [0.00 0.45 0.74];   % Blue
    colorCleaned    = [0.13 0.55 0.13];   % Green
    colorNormalized = [0.85 0.33 0.10];   % Red

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

    %% 6. Single figure + three subplots (combined into one figure)
    fig = figure('Color', 'w', 'Position', [80 80 1100 600]);
    t = tiledlayout(3, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

    % ---- Subplot 1: Original data ----
    nexttile;
    plot(dates, original, 'Color', colorOriginal, 'LineWidth', 1.2);
    grid on; box on;
    ylabel('Index Value', 'FontName', fontCN);
    title(sprintf('Original Data (%s)', seriesName), ...
          'FontName', fontCN, 'FontSize', 11);

    xlim([dates(1) dates(end)]);

    % ---- Subplot 2: Cleaned data ----
    nexttile;
    plot(dates, cleaned, 'Color', colorCleaned, 'LineWidth', 1.2);
    grid on; box on;
    ylabel('Index Value', 'FontName', fontCN);
    title('Cleaned Data (missing values and outliers handled)', ...
          'FontName', fontCN, 'FontSize', 11);

    xlim([dates(1) dates(end)]);

    % ---- Subplot 3: Normalized data ----
    nexttile;
    plot(dates, normalized, 'Color', colorNormalized, 'LineWidth', 1.2);
    grid on; box on;
    ylabel('Normalized Value', 'FontName', fontCN);
    xlabel('Date', 'FontName', fontCN);
    title('Normalized Data (Min-Max scaled to [0, 1])', ...
          'FontName', fontCN, 'FontSize', 11);

    xlim([dates(1) dates(end)]);

    %% 7. Uniform x-axis: every January
    yearsAll  = year(dates);
    uniqYears = unique(yearsAll);
    janIdx = arrayfun(@(y) find(year(dates)==y & month(dates)==1, 1, 'first'), uniqYears);

    axAll = findall(fig, 'Type', 'axes');
    for k = 1:numel(axAll)
        axAll(k).XTick = dates(janIdx);
        axAll(k).XTickLabelRotation = 0;
    end
    monthNames = {'Jan','Feb','Mar','Apr','May','Jun', ...
                  'Jul','Aug','Sep','Oct','Nov','Dec'};
    bottomLabels = cell(numel(janIdx),1);
    for i = 1:numel(janIdx)
        d = dates(janIdx(i));
        bottomLabels{i} = sprintf('%s %d', monthNames{month(d)}, year(d));
    end
    for k = 1:numel(axAll)
        axAll(k).XTickLabel = bottomLabels;
    end

    % Overall title
    title(t, sprintf('Data Preprocessing Flow - %s', seriesName), ...
          'FontName', fontCN, 'FontSize', 13, 'FontWeight', 'bold');

    %% 8. Export as a single image (containing three subplots)
    outName = sprintf('%s_Preprocessing_Flow.png', datasetName);
    % exportgraphics supports tiledlayout well
    exportgraphics(fig, outName, 'Resolution', 300);
    fprintf('Preprocessing flow figure exported as: %s\n', outName);

end