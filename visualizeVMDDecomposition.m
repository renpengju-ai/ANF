function visualizeVMDDecomposition(signal, kValues)
% visualizeVMDDecomposition - 可视化不同K值下的VMD分解结果
% 输入:
%   signal - 要分解的信号
%   kValues - 要比较的K值数组 (如 [3, 5, 7])

if nargin < 2
    kValues = [3, 5, 7]; % 默认比较这三个K值
end

% 创建主图形窗口
figure('Name', '不同K值下的VMD分解结果比较', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 800]);

% 子图数量
nRows = length(kValues) + 1;
plotIdx = 1;

% 绘制原始信号
subplot(nRows, 1, plotIdx);
plot(signal, 'k', 'LineWidth', 1.5);
title('原始信号', 'FontSize', 12);
xlabel('时间');
ylabel('幅值');
grid on;
plotIdx = plotIdx + 1;

% 为每个K值绘制分解结果
colorMap = jet(max(kValues)); % 为不同IMF创建颜色映射

for k = kValues
    % 使用VMD进行分解
    [imf, residual] = vmd(signal, 'NumIMF', k);
    
    % 绘制该K值下的所有IMF
    subplot(nRows, 1, plotIdx);
    hold on;
    
    % 绘制每个IMF
    for i = 1:k
        plot(imf(:,i), 'Color', colorMap(i,:), 'LineWidth', 1);
    end
    
    % 绘制残差
    plot(residual, 'k--', 'LineWidth', 1);
    
    title(['VMD分解 (K = ' num2str(k) ')'], 'FontSize', 12);
    xlabel('时间');
    ylabel('幅值');
    grid on;
    
    % 创建图例
    legendEntries = cell(1, k+1);
    for i = 1:k
        legendEntries{i} = ['IMF' num2str(i)];
    end
    legendEntries{k+1} = '残差';
    legend(legendEntries, 'Location', 'eastoutside');
    
    hold off;
    plotIdx = plotIdx + 1;
end

% 保存图像
saveas(gcf, 'VMD_Decomposition_Comparison.png');
saveas(gcf, 'VMD_Decomposition_Comparison.fig');
fprintf('VMD分解比较图已保存为 VMD_Decomposition_Comparison.png 和 VMD_Decomposition_Comparison.fig\n');

% 绘制IMF频谱分析（只针对最佳K值 - 假设是传入的最后一个K值）
bestK = kValues(end);
[imf, ~] = vmd(signal, 'NumIMF', bestK);

try
    figure('Name', ['VMD分解频谱分析 (K = ' num2str(bestK) ')'], 'NumberTitle', 'off', 'Position', [100, 100, 1200, 800]);
    
    % 计算频谱
    fs = 1; % 假设采样频率为1
    nfft = 2^nextpow2(length(signal));
    f = (0:nfft/2-1)*fs/nfft;
    
    % 设置子图布局
    nRows = ceil(bestK/2);
    nCols = min(2, bestK);
    
    % 绘制每个IMF的频谱
    for i = 1:bestK
        subplot(nRows, nCols, i);
        
        % 计算频谱
        Y = fft(imf(:,i), nfft)/length(imf(:,i));
        Y_mag = abs(Y(1:nfft/2));
        
        % 确保colorMap索引在有效范围内
        colorIndex = min(i, size(colorMap, 1));
        
        % 绘制频谱
        plot(f, Y_mag, 'Color', colorMap(colorIndex,:), 'LineWidth', 1.5);
        
        title(['IMF' num2str(i) ' 频谱'], 'FontSize', 10);
        xlabel('频率');
        ylabel('幅值');
        grid on;
        
        % 标记主频
        [maxVal, maxIdx] = max(Y_mag);
        if maxVal > 0.01
            hold on;
            plot(f(maxIdx), maxVal, 'ro', 'MarkerSize', 8, 'LineWidth', 1.5);
            text(f(maxIdx), maxVal, [' f = ' num2str(f(maxIdx), '%.4f')], 'VerticalAlignment', 'bottom');
            hold off;
        end
    end
    
    % 保存频谱分析图
    saveas(gcf, ['VMD_Spectral_Analysis_K' num2str(bestK) '.png']);
    saveas(gcf, ['VMD_Spectral_Analysis_K' num2str(bestK) '.fig']);
    fprintf('频谱分析图已保存为 VMD_Spectral_Analysis_K%d.png 和 VMD_Spectral_Analysis_K%d.fig\n', bestK, bestK);
catch e
    % 如果发生错误，输出错误信息但不中断程序
    fprintf('绘制频谱分析图时出错: %s\n', e.message);
end
end 