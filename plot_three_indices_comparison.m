function plot_three_indices_comparison_v3()
% 优化版 V3：绘制三个股票指数（HSI, S&P 500, SSE）的标准化数据对比图
%
% 更新内容：
% 1. 修复 S&P 子图可能缺失 2017 年刻度的问题（改用 datetime 直接定位刻度）。
% 2. 横坐标日期格式调整为 "Jan 2010" 样式。
% 3. 字体保持 Times New Roman，移除顶部总标题。
%
% 依赖文件 (需在 Benchmarks 目录下):
%   Benchmarks/HSI_Index.mat
%   Benchmarks/SandP_Index.mat
%   Benchmarks/SSE_Index.mat

    clc; close all;

    %% 0. 全局设置
    fontName = 'Times New Roman';
    % 数据集定义
    datasetList = {
        'HSI_Index',   'Hang Seng Index (HSI) - Normalized Data';
        'SandP_Index', 'S&P 500 Index (S&P 500) - Normalized Data';
        'SSE_Index',   'Shanghai Composite Index (SSE) - Normalized Data'
    };
    
    numDatasets = size(datasetList, 1);
    
    %% 1. 创建画布
    fig = figure('Color', 'w', 'Position', [100 100 1100 600]);
    t = tiledlayout(numDatasets, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
    
    axAll = gobjects(numDatasets, 1); 

    %% 2. 循环处理并绘图
    for i = 1:numDatasets
        dName = datasetList{i, 1};
        dTitle = datasetList{i, 2};
        
        % --- 2.1 加载与预处理 ---
        [dates, normalizedData] = load_and_process(dName);
        
        % --- 2.2 绘图 ---
        axAll(i) = nexttile;
        plot(dates, normalizedData, 'Color', [0.00, 0.45, 0.74], 'LineWidth', 1.2);
        
        % --- 2.3 样式设置 ---
        grid on; box on;
        
        % 设置 X 轴范围 (紧贴数据)
        xlim([dates(1), dates(end)]);
        % 设置 Y 轴范围
        ylim([-0.05, 1.05]); 
        
        % 标签设置
        ylabel('Normalized Value [0, 1]', 'FontName', fontName, 'FontSize', 10);
        title(dTitle, 'FontName', fontName, 'FontSize', 11, 'FontWeight', 'bold');
        
        % 仅最底部显示 "Date" 总标签
        if i == numDatasets
            xlabel('Date', 'FontName', fontName, 'FontSize', 11);
        end
        
        % --- 2.4 关键修改：生成 "Jan 2010" 格式的刻度 ---
        % 获取当前数据的年份范围
        yStart = year(dates(1));
        yEnd   = year(dates(end));
        
        % 生成从起始年到结束年，每年的 1月1日 的时间点
        tickDates = datetime(yStart:yEnd, 1, 1);
        
        % 应用刻度位置 (直接使用 datetime 对象，确保不同长度数据集对齐准确)
        axAll(i).XTick = tickDates;
        
        % 生成 "Jan 2010" 格式的标签
        % datestr 返回的是 char 矩阵，转为 string 数组以免格式错乱
        tickLabels = string(datestr(tickDates, 'mmm yyyy')); 
        axAll(i).XTickLabel = tickLabels;
        
        % 强制设置字体
        set(gca, 'FontName', fontName, 'FontSize', 10);
    end

    %% 3. 联动与导出
    linkaxes(axAll, 'x'); % 联动 X 轴
    
    outName = 'Three_Indices_Comparison_JanFormat.png';
    exportgraphics(fig, outName, 'Resolution', 300);
    fprintf('Figure exported as: %s\n', outName);
end

%% ================= 辅助函数：加载与清洗逻辑 =================
function [dates, normalized] = load_and_process(datasetName)
    % 1. Load Data
    dataFile = fullfile('Benchmarks', [datasetName '.mat']);
    if ~isfile(dataFile)
        error('Data file not found: %s', dataFile);
    end
    S = load(dataFile);
    if isfield(S, 'data')
        x = S.data(:, 1);
    else
        fns = fieldnames(S);
        x = S.(fns{1});
        if size(x, 2) > 1, x = x(:, 1); end
    end
    x = x(:);
    N = numel(x);

    % 2. Construct Date Axis (Assuming start from 2010-01-01)
    startDate = datetime(2010, 1, 1);
    dates = startDate + caldays(0:N-1)';

    % 3. Preprocess (Cleaning)
    original = x;
    cleaned = fillmissing(original, 'linear');
    win  = 5;
    med  = movmedian(cleaned, win, 'omitnan');
    diffVal = cleaned - med;
    thr  = 3 * std(diffVal, 'omitnan');
    mask = abs(diffVal) > thr;
    cleaned(mask) = med(mask);

    % 4. Normalize (Min-Max to [0,1])
    minVal = min(cleaned);
    maxVal = max(cleaned);
    if maxVal > minVal
        normalized = (cleaned - minVal) ./ (maxVal - minVal);
    else
        normalized = zeros(size(cleaned));
    end
end