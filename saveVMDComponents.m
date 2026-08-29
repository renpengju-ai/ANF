function saveVMDComponents(signal, optimalK, datasetName, outputFolder)
% saveVMDComponents - 保存VMD分解后的原始序列和各个IMF分量图像
% 输入:
%   signal - 原始信号
%   optimalK - 最优的K值（IMF数量）
%   datasetName - 数据集名称（如 'HSI_Index', 'SSE_Index'）
%   outputFolder - 输出文件夹路径（可选，默认为 'VMD_Components_Figures'）

if nargin < 4
    outputFolder = 'VMD_Components_Figures';
end

% 创建数据集专属的子文件夹
datasetFolder = fullfile(outputFolder, datasetName);
if ~exist(datasetFolder, 'dir')
    mkdir(datasetFolder);
    fprintf('创建文件夹: %s\n', datasetFolder);
end

% 1. 保存原始序列图像
fprintf('生成并保存 %s 的原始序列图像...\n', datasetName);
% 去掉数据集名称中的"_Index"后缀用于标题显示
displayName = strrep(datasetName, '_Index', '');
fig = figure('Visible', 'off', 'Position', [100, 100, 800, 300]);
plot(signal, 'Color', [0, 0.447, 0.741], 'LineWidth', 1.5);
title(sprintf('%s Time Series', displayName), 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Time Step', 'FontSize', 10);
ylabel('Value', 'FontSize', 10);
xlim([1, length(signal)]);  % 让曲线右端紧贴边界
grid on;
box on;

% 保存原始序列图
originalFile = fullfile(datasetFolder, sprintf('%s_Original.png', datasetName));
saveas(fig, originalFile);
fprintf('  已保存: %s\n', originalFile);
close(fig);

% 2. 使用VMD进行分解
fprintf('对 %s 进行VMD分解 (K=%d)...\n', datasetName, optimalK);
[imf, residual] = vmd(signal, 'NumIMF', optimalK);

% 3. 为每个IMF分量单独保存图像
fprintf('生成并保存各个IMF分量图像...\n');
for i = 1:optimalK
    fig = figure('Visible', 'off', 'Position', [100, 100, 800, 300]);
    plot(imf(:,i), 'Color', [0, 0.447, 0.741], 'LineWidth', 1.2);
    title(sprintf('IMF%d Component', i), 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Time Step', 'FontSize', 10);
    ylabel('IMF', 'FontSize', 10);
    xlim([1, size(imf, 1)]);  % 让曲线右端紧贴边界
    grid on;
    box on;
    
    % 保存IMF图
    imfFile = fullfile(datasetFolder, sprintf('IMF%d.png', i));
    saveas(fig, imfFile);
    fprintf('  已保存: IMF%d.png\n', i);
    close(fig);
end

% 4. 可选：保存残差图像（如果需要）
fig = figure('Visible', 'off', 'Position', [100, 100, 800, 300]);
plot(residual, 'r', 'LineWidth', 1.2);
title('Residual Component', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Time Step', 'FontSize', 10);
ylabel('Residual', 'FontSize', 10);
xlim([1, length(residual)]);  % 让曲线右端紧贴边界
grid on;
box on;

residualFile = fullfile(datasetFolder, 'Residual.png');
saveas(fig, residualFile);
fprintf('  已保存: Residual.png\n');
close(fig);

fprintf('\n%s 的所有VMD分量图像已保存至: %s\n', datasetName, datasetFolder);
fprintf('共生成 %d 张图片（原始序列 + %d个IMF + 残差）\n\n', optimalK+2, optimalK);

end
