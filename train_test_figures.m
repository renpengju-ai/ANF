%% S&P500 训练/测试集时间序列图（使用 Benchmarks/SandP_Index.mat 全部数据）
clear; clc; close all;

%% 0. 字体设置 —— 确保中文正常显示
% 如果没有 Microsoft YaHei，可以改成 'SimHei'、'宋体' 等
fontCN = 'Microsoft YaHei';
set(0, 'defaultAxesFontName', fontCN);
set(0, 'defaultTextFontName', fontCN);

%% 1. 加载 Benchmarks/SandP_Index.mat 全部数据
dataFile = fullfile('Benchmarks', 'SSE_Index.mat');
S = load(dataFile);

% 尽量兼容不同字段名
if isfield(S, 'data')
    idx = S.data(:, 1);          % 取第一列指数
else
    fn  = fieldnames(S);
    idx = S.(fn{1});
    if size(idx, 2) > 1
        idx = idx(:, 1);
    end
end
idx = idx(:);                    % 列向量
N   = numel(idx);                % 使用全部样本点

%% 2. 构造日期轴 & 8:2 训练/测试划分
% 如已知真实起始日期，可将 2010-01-01 改为实际日期
startDate = datetime(2010, 1, 1);
dates = startDate + caldays(0:N-1)';

splitIdx  = floor(0.8 * N);      % 8:2 划分
dateTrain = dates(1:splitIdx);
dateTest  = dates(splitIdx+1:end);
yTrain    = idx(1:splitIdx);
yTest     = idx(splitIdx+1:end);

%% 3. 纵轴范围
yMin    = min(idx);
yMax    = max(idx);
yMargin = 0.05 * (yMax - yMin);
if yMargin == 0, yMargin = 1; end
yLim = [yMin - yMargin, yMax + yMargin];

%% 4. 绘图
fig = figure('Color', 'w', 'Position', [100 100 1000 420]);
hold on;

% 测试集区域阴影（淡紫色）
xPatch = [dateTest(1) dateTest(end) dateTest(end) dateTest(1)];
yPatch = [yLim(1)     yLim(1)       yLim(2)       yLim(2)];
hPatch = patch(xPatch, yPatch, [0.93 0.85 0.97], ...
    'EdgeColor', 'none', 'FaceAlpha', 0.7);

% 训练集 / 测试集曲线
trainColor = [0.0 0.60 0.0];     % 绿色
testColor  = [0.70 0.00 0.80];   % 紫色

pTrain = plot(dateTrain, yTrain, ...
    'Color', trainColor, 'LineWidth', 1.5);
pTest  = plot(dateTest,  yTest,  ...
    'Color', testColor,  'LineWidth', 1.5);

% 把阴影放到曲线下方
uistack(hPatch, 'bottom');

%% 5. 坐标轴 & 网格 & 标签
grid on; box on;
xlim([dates(1) dates(end)]);
ylim(yLim);

ax = gca;
set(ax, ...
    'LineWidth', 1, ...
    'XGrid', 'on', 'YGrid', 'on', ...
    'Layer', 'top', ...
    'FontSize', 10);

% —— 横坐标刻度：每年 1 月；标签用英文 "Jan 2010" 形式 ——
yearsAll = year(dates);
uniqYears = unique(yearsAll);
janIdx = arrayfun(@(y) find(year(dates)==y & month(dates)==1, 1, 'first'), uniqYears);
ax.XTick = dates(janIdx);

monthNames = {'Jan','Feb','Mar','Apr','May','Jun', ...
              'Jul','Aug','Sep','Oct','Nov','Dec'};
labels = cell(numel(janIdx),1);
for i = 1:numel(janIdx)
    d = dates(janIdx(i));
    labels{i} = sprintf('%s %d', monthNames{month(d)}, year(d));
end
ax.XTickLabel = labels;   % 强制英文月份

xlabel('日期 (Date)', 'FontSize', 11, 'FontName', fontCN);
ylabel('指数值',      'FontSize', 11, 'FontName', fontCN);

title('上证指数 (SSE)', ...
    'FontSize', 12, 'FontWeight', 'bold', 'FontName', fontCN);

legend([pTrain, pTest], ...
    {'训练集 (Train)', '测试集 (Test)'}, ...
    'Location', 'northwest', 'Box', 'on', ...
    'FontSize', 10, 'FontName', fontCN);

%% 6. 可选：保存图像
% saveas(fig, 'SandP_Train_Test_Split.png');