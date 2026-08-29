function plot_preprocessing_flow(datasetName)
% 绘制数据预处理流程图（原始 -> 清洗 -> 标准化）
% 修复版：解决了老版本 MATLAB 无法识别 t.FontName 的报错
% 修复版2：解决中文乱码问题，使用支持中文的字体
%
% 调用示例：
%   plot_preprocessing_flow('HSI_Index');
%   plot_preprocessing_flow('SSE_Index');
%   plot_preprocessing_flow('SandP_Index');

%20260518 图中英文修改为中文

    if nargin < 1
        datasetName = 'SSE_Index';   % Default S&P 500 Index
    end

    %% 0. Font setting - 修改：使用支持中文的字体
    % 根据不同操作系统选择合适的支持中文的字体
    if ismac
        % Mac系统
        fontCN = 'Heiti SC';  % 黑体
        % 备选: 'STHeiti', 'PingFang SC'
    elseif isunix
        % Linux系统
        fontCN = 'WenQuanYi Micro Hei';  % 文泉驿微米黑
        % 备选: 'Noto Sans CJK SC'
    else
        % Windows系统
        fontCN = 'SimHei';  % 黑体
        % 备选: 'Microsoft YaHei', 'STHeiti'
    end
    
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

    %% 5. Dataset English name - 修改：确保中文正确显示
    switch datasetName
        case 'HSI_Index'
            seriesName = '恒生指数 (HSI)';
        case 'SSE_Index'
            seriesName = '上证指数 (SSE)';
        case 'SandP_Index'
            seriesName = '标准普尔500指数 (S&P 500)';
        otherwise
            seriesName = datasetName;
    end

    %% 6. Single figure + three subplots
    fig = figure('Color', 'w', 'Position', [80 80 1100 600]);
    
    t = tiledlayout(3, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
    
    % ---- Subplot 1: Original ----
    ax1 = nexttile;
    plot(dates, original, 'Color', colorOriginal, 'LineWidth', 1.2);
    grid on; box on;
    ylabel('指数值');
    title(sprintf('原始数据 (%s)', seriesName), 'FontSize', 11);
    xlim([dates(1) dates(end)]);

    % ---- Subplot 2: Cleaned ----
    ax2 = nexttile;
    plot(dates, cleaned, 'Color', colorCleaned, 'LineWidth', 1.2);
    grid on; box on;
    ylabel('指数值');
    title('清洗后的数据（缺失值和异常值已处理）', 'FontSize', 11);
    xlim([dates(1) dates(end)]);

    % ---- Subplot 3: Normalized ----
    ax3 = nexttile;
    plot(dates, normalized, 'Color', colorNormalized, 'LineWidth', 1.2);
    grid on; box on;
    ylabel('归一化值');
    xlabel('日期');
    title('归一化数据（归一化到[0, 1]区间）', 'FontSize', 11);
    xlim([dates(1) dates(end)]);
    
    % 联动缩放
    linkaxes([ax1, ax2, ax3], 'x');

    %% 7. Uniform x-axis & Font Application - 修改：增强字体设置
    % 生成横坐标标签："2010年1月"格式
    yearsAll  = year(dates);
    uniqYears = unique(yearsAll);
    
    % 为每一年选择1月份的索引（如果没有1月数据，则选择该年第一个月）
    janIdx = zeros(length(uniqYears), 1);
    for i = 1:length(uniqYears)
        yearData = uniqYears(i);
        yearIndices = find(year(dates) == yearData);
        % 查找该年1月份的数据
        janIndices = find(year(dates) == yearData & month(dates) == 1);
        if ~isempty(janIndices)
            janIdx(i) = janIndices(1);
        else
            % 如果没有1月数据，使用该年第一个数据点
            janIdx(i) = yearIndices(1);
        end
    end
    
    axAll = [ax1, ax2, ax3]; 
    
    % 创建中文格式的标签："2010年1月"
    bottomLabels = cell(numel(janIdx),1);
    for i = 1:numel(janIdx)
        d = dates(janIdx(i));
        bottomLabels{i} = sprintf('%d年%d月', year(d), month(d));
    end

    % 统一设置 Tick 和字体 - 修改：增强中文支持
    for k = 1:numel(axAll)
        axAll(k).XTick = dates(janIdx);
        axAll(k).XTickLabelRotation = 0;
        axAll(k).XTickLabel = bottomLabels;
        
        % 修改点：使用支持中文的字体
        axAll(k).FontName = fontCN;
        axAll(k).FontSize = 10;  % 设置合适字体大小
        
        % 设置标题、标签字体
        set(axAll(k).Title, 'FontName', fontCN, 'FontSize', 11);
        set(axAll(k).XLabel, 'FontName', fontCN, 'FontSize', 10);
        set(axAll(k).YLabel, 'FontName', fontCN, 'FontSize', 10);
    end
    
    % 额外设置：确保图形窗口也支持中文显示
    set(0, 'DefaultAxesFontName', fontCN);
    set(0, 'DefaultTextFontName', fontCN);
    
    %% 8. Export - 修改：增加高清导出设置
    outName = sprintf('%s_Preprocessing_Flow.png', datasetName);
    % 使用更高的分辨率，并确保字体嵌入
    exportgraphics(fig, outName, 'Resolution', 300, 'ContentType', 'auto');
    fprintf('预处理流程图已导出为: %s\n', outName);
    
    % 可选：同时保存为fig格式以便后续修改
    % savefig(fig, sprintf('%s_Preprocessing_Flow.fig', datasetName));
end