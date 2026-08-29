function [optimalK, scores] = findOptimalIMFNumber(signal, maxK, plotScores)
% findOptimalIMFNumber - 根据MEMD的分解原理自适应确定VMD的最佳K值
% 输入:
%   signal - 要分解的信号
%   maxK - 最大IMF数量的上限
%   plotScores - 是否绘制评分曲线图 (默认为false)
% 输出:
%   optimalK - 最佳的IMF数量
%   scores - 各K值对应的评分

% 处理可选参数
if nargin < 3
    plotScores = false;
end

% 初始化
optimalK = 2; % 最小从2开始
bestScore = inf;
scores = zeros(maxK-1, 1);
lastK = 0; % 记录最后评估的K值

% 对不同的K值进行评估
for k = 2:maxK
    fprintf('评估K=%d时的分解效果...\n', k);
    lastK = k; % 更新最后评估的K值
    
    % 使用VMD进行分解
    [imf, residual] = vmd(signal, 'NumIMF', k);
    
    % 计算评估指标
    % 1. 计算残差能量
    residualEnergy = sum(residual.^2);
    
    % 2. 计算IMF的正交性 (类似MEMD的标准)
    orthogonalityScore = 0;
    for i = 1:k
        for j = i+1:k
            % 计算IMF之间的相关性
            correlation = abs(sum(imf(:,i) .* imf(:,j)) / (norm(imf(:,i)) * norm(imf(:,j))));
            orthogonalityScore = orthogonalityScore + correlation;
        end
    end
    
    % 3. 判断候选IMF的有效性 (根据MEMD中的标准)
    imfValidityScore = 0;
    for i = 1:k
        % 计算局部极值点数量
        [maxPeaks, ~] = findpeaks(imf(:,i));
        [minPeaks, ~] = findpeaks(-imf(:,i));
        totalPeaks = length(maxPeaks) + length(minPeaks);
        
        % 信号长度
        signalLength = length(imf(:,i));
        
        % 极值点比例（应该在合理范围内）
        peakRatio = totalPeaks / signalLength;
        
        % 如果极值点太少或太多，增加惩罚
        if peakRatio < 0.01 || peakRatio > 0.5
            imfValidityScore = imfValidityScore + 1;
        end
        
        % 计算IMF的频谱集中度
        fftIMF = abs(fft(imf(:,i)));
        fftIMF = fftIMF(1:floor(length(fftIMF)/2));
        spectralConcentration = sum(fftIMF.^4) / (sum(fftIMF.^2)^2);
        
        % 频谱集中度应该相对较高
        imfValidityScore = imfValidityScore + (1 / spectralConcentration);
    end
    
    % 添加复杂度惩罚
    n = length(signal);
    complexityPenalty = k * log(n);  % BIC风格的惩罚
    
    % 改进的适应度函数
    combinedScore = residualEnergy + orthogonalityScore * 10 + imfValidityScore * 5 + complexityPenalty * 5e3;
    
    scores(k-1) = combinedScore;
    
    fprintf('  K=%d 的评分: %f (残差能量: %f, 正交性: %f, IMF有效性: %f)\n', ...
        k, combinedScore, residualEnergy, orthogonalityScore, imfValidityScore);
    
    % 找到最佳K值
    if combinedScore < bestScore
        bestScore = combinedScore;
        optimalK = k;
    end
    
    % 如果分数开始恶化，可以提前终止
    if k > 3 && scores(k-1) > scores(k-2) * 1.5
        fprintf('分数开始明显恶化，提前终止评估\n');
        break;
    end
end

% 显示评估结果
fprintf('最佳IMF数量为: %d (评分: %f)\n', optimalK, scores(optimalK-1));

% 绘制评分曲线图
if plotScores
    % 准备有效的数据点 - 只使用实际计算过的K值
    validK = 2:lastK;
    validScores = scores(1:(lastK-1));
    
    % 创建图形
    figure('Name', 'VMD最佳K值评估', 'NumberTitle', 'off');
    
    % 绘制评分曲线
    plot(validK, validScores, 'b-o', 'LineWidth', 2);
    hold on;
    
    % 标记最佳K值点
    plot(optimalK, scores(optimalK-1), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
    
    % 添加标签和标题
    xlabel('IMF数量 (K)', 'FontSize', 12);
    ylabel('综合评分 (越低越好)', 'FontSize', 12);
    title('不同K值下的VMD分解评分', 'FontSize', 14);
    
    % 添加网格和图例
    grid on;
    legend('评分曲线', '最佳K值', 'Location', 'best');
    
    % 优化显示
    xlim([min(validK)-0.5, max(validK)+0.5]);
    xticks(validK);
    
    % 添加文本标注
    text(optimalK, scores(optimalK-1), [' 最佳K = ', num2str(optimalK)], ...
        'VerticalAlignment', 'bottom', 'FontSize', 10);
    
    % 保存图像
    saveas(gcf, 'VMD_K_Evaluation.png');
    saveas(gcf, 'VMD_K_Evaluation.fig');
    fprintf('评分曲线图已保存为 VMD_K_Evaluation.png 和 VMD_K_Evaluation.fig\n');
end
end 