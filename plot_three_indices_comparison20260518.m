function plot_three_indices_comparison_v3()
% 优化版 V3：绘制三个股票指数（HSI, S&P 500, SSE）的标准化数据对比图
%
% 20260518更新内容：
% 1. 修复 S&P 子图可能缺失 2017 年刻度的问题（改用 datetime 直接定位刻度）。
% 2. 横坐标日期格式调整为中文格式。
% 3. 所有坐标轴标签和标题改为中文。
%
% 依赖文件 (需在 Benchmarks 目录下):
%   Benchmarks/HSI_Index.mat
%   Benchmarks/SandP_Index.mat
%   Benchmarks/SSE_Index.mat

    clc; close all;

    %% 0. 全局设置 - 修改：使用支持中文的字体
    % 根据不同操作系统选择合适的支持中文的字体
    if ismac
        % Mac系统
        fontName = 'Heiti SC';  % 黑体
    elseif isunix
        % Linux系统
        fontName = 'WenQuanYi Micro Hei';  % 文泉驿微米黑
    else
        % Windows系统
        fontName = 'SimHei';  % 黑体
    end
    
    % 数据集定义 - 修改：标题改为中文
    datasetList = {
        'HSI_Index',   '恒生指数 (HSI) - 归一化数据';
        'SandP_Index', '标准普尔500指数 (S&P 500) - 归一化数据';
        'SSE_Index',   '上证综合指数 (SSE) - 归一化数据'
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
        
        % 修改：Y轴标签改为中文
        ylabel('标准化数值 [0, 1]', 'FontName', fontName, 'FontSize', 10);
        % 修改：标题字体支持中文
        title(dTitle, 'FontName', fontName, 'FontSize', 11, 'FontWeight', 'bold');
        
        % 修改：仅最底部显示 "日期" 总标签
        if i == numDatasets
            xlabel('日期', 'FontName', fontName, 'FontSize', 11);
        end
        
        % --- 2.4 修改：生成中文格式 "2010年1月" 的刻度 ---
        % 获取当前数据的年份范围
        yStart = year(dates(1));
        yEnd   = year(dates(end));
        
        % 生成从起始年到结束年，每年的 1月1日 的时间点
        tickDates = datetime(yStart:yEnd, 1, 1);
        
        % 应用刻度位置 (直接使用 datetime 对象，确保不同长度数据集对齐准确)
        axAll(i).XTick = tickDates;
        
        % 修改：生成 "2010年1月" 格式的中文标签
        tickLabels = cell(length(tickDates), 1);
        for j = 1:length(tickDates)
            tickLabels{j} = sprintf('%d年%d月', year(tickDates(j)), month(tickDates(j)));
        end
        axAll(i).XTickLabel = tickLabels;
        
        % 修改：强制设置支持中文的字体
        set(gca, 'FontName', fontName, 'FontSize', 10);
        
        % 修改：额外设置刻度标签字体
        axAll(i).XTickLabelRotation = 0;  % 不旋转，保持水平
    end

    %% 3. 联动与导出
    linkaxes(axAll, 'x'); % 联动 X 轴
    
    % 修改：输出文件名保持不变
    outName = 'Three_Indices_Comparison_Chinese.png';
    exportgraphics(fig, outName, 'Resolution', 300);
    fprintf('图表已导出为: %s\n', outName);
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