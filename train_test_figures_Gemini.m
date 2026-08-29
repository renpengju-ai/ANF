
%% S&P500 Train/Test Split Time Series Plot
% Using Benchmarks/SandP_Index.mat
clear; clc; close all;

%% 0. Font Settings (Times New Roman)
fontName = 'Times New Roman';

% Apply global settings for this session (optional but ensures consistency)
set(0, 'defaultAxesFontName', fontName);
set(0, 'defaultTextFontName', fontName);

%% 1. Load Data (Benchmarks/SandP_Index.mat)
datasetName = 'SSE_Index';
dataFile = fullfile('Benchmarks', [datasetName '.mat']);

% Check if file exists to avoid crash
if ~isfile(dataFile)
    error('File not found: %s', dataFile);
end

S = load(dataFile);
% Compatible loading logic
if isfield(S, 'data')
    idx = S.data(:, 1);
else
    fn  = fieldnames(S);
    idx = S.(fn{1});
    if size(idx, 2) > 1
        idx = idx(:, 1);
    end
end
idx = idx(:);                    % Column vector
N   = numel(idx);                % Total samples

%% 2. Date Axis & 80/20 Split
% Start date assumed 2010-01-01
startDate = datetime(2010, 1, 1);
dates = startDate + caldays(0:N-1)';

splitIdx  = floor(0.8 * N);      % 80% split point
dateTrain = dates(1:splitIdx);
dateTest  = dates(splitIdx+1:end);
yTrain    = idx(1:splitIdx);
yTest     = idx(splitIdx+1:end);

%% 3. Y-Axis Limits
yMin    = min(idx);
yMax    = max(idx);
yMargin = 0.05 * (yMax - yMin);
if yMargin == 0, yMargin = 1; end
yLim = [yMin - yMargin, yMax + yMargin];

%% 4. Plotting
fig = figure('Color', 'w', 'Position', [100 100 1000 420]);
hold on;

% Test set shaded area (Light Purple)
xPatch = [dateTest(1) dateTest(end) dateTest(end) dateTest(1)];
yPatch = [yLim(1)     yLim(1)       yLim(2)       yLim(2)];
hPatch = patch(xPatch, yPatch, [0.93 0.85 0.97], ...
    'EdgeColor', 'none', 'FaceAlpha', 0.7);

% Train / Test Lines
trainColor = [0.0 0.60 0.0];     % Green
testColor  = [0.70 0.00 0.80];   % Purple

pTrain = plot(dateTrain, yTrain, ...
    'Color', trainColor, 'LineWidth', 1.5);
pTest  = plot(dateTest,  yTest,  ...
    'Color', testColor,  'LineWidth', 1.5);

% Move shading to bottom layer
uistack(hPatch, 'bottom');

%% 5. Axes, Grid & Labels (English)
grid on; box on;
xlim([dates(1) dates(end)]);
ylim(yLim);

ax = gca;
set(ax, ...
    'LineWidth', 1, ...
    'XGrid', 'on', 'YGrid', 'on', ...
    'Layer', 'top', ...
    'FontSize', 10, ...
    'FontName', fontName); % Ensure axes font is Times New Roman

% -- X-Axis Ticks: Every January --
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
ax.XTickLabel = labels;

% -- Labels & Title in English --
xlabel('Date',        'FontSize', 11, 'FontName', fontName);
ylabel('Index Value', 'FontSize', 11, 'FontName', fontName);
title('SSE', ...
    'FontSize', 12, 'FontWeight', 'bold', 'FontName', fontName);

% -- Legend in English --
legend([pTrain, pTest], ...
    {'Training Set', 'Testing Set'}, ...
    'Location', 'northwest', 'Box', 'on', ...
    'FontSize', 10, 'FontName', fontName);

%% 6. Export (Optional)
outName = sprintf('%s_Train_Test_Split.png', datasetName);
% exportgraphics(fig, outName, 'Resolution', 300); % Uncomment to save