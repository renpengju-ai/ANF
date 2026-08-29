function analyzeScoreComponents(signal, maxK)
% analyzeScoreComponents - 分析和可视化combinedScore的各组成部分
% 输入:
%   signal - 要分解的信号
%   maxK - 最大IMF数量的上限

if nargin < 2
    maxK = 10; % 默认最大K值
end

% 初始化存储数组
kValues = 2:maxK;
residualEnergies = zeros(length(kValues), 1);
orthogonalityScores = zeros(length(kValues), 1);
imfValidityScores = zeros(length(kValues), 1);
complexityPenalties = zeros(length(kValues), 1); % 新增复杂度惩罚数组
combinedScores = zeros(length(kValues), 1);
lastIdx = 0; % 记录最后实际计算的索引

% 对不同的K值进行评估
for i = 1:length(kValues)
    k = kValues(i);
    fprintf('分析K=%d的评分组成...\n', k);
    lastIdx = i; % 更新最后计算的索引
    
    % 使用VMD进行分解
    [imf, residual] = vmd(signal, 'NumIMF', k);
    
    % 1. 计算残差能量
    residualEnergies(i) = sum(residual.^2);
    
    % 2. 计算IMF的正交性
    orthogonalityScores(i) = 0;
    for j = 1:k
        for l = j+1:k
            % 计算IMF之间的相关性
            correlation = abs(sum(imf(:,j) .* imf(:,l)) / (norm(imf(:,j)) * norm(imf(:,l))));
            orthogonalityScores(i) = orthogonalityScores(i) + correlation;
        end
    end
    
    % 3. 判断候选IMF的有效性
    imfValidityScores(i) = 0;
    for j = 1:k
        % 计算局部极值点数量
        [maxPeaks, ~] = findpeaks(imf(:,j));
        [minPeaks, ~] = findpeaks(-imf(:,j));
        totalPeaks = length(maxPeaks) + length(minPeaks);
        
        % 信号长度
        signalLength = length(imf(:,j));
        
        % 极值点比例
        peakRatio = totalPeaks / signalLength;
        
        % 如果极值点太少或太多，增加惩罚
        if peakRatio < 0.01 || peakRatio > 0.5
            imfValidityScores(i) = imfValidityScores(i) + 1;
        end
        
        % 计算IMF的频谱集中度
        fftIMF = abs(fft(imf(:,j)));
        fftIMF = fftIMF(1:floor(length(fftIMF)/2));
        spectralConcentration = sum(fftIMF.^4) / (sum(fftIMF.^2)^2);
        
        % 频谱集中度应该相对较高
        imfValidityScores(i) = imfValidityScores(i) + (1 / spectralConcentration);
    end
    
    % 4. 计算复杂度惩罚 (BIC风格)
    n = length(signal);
    complexityPenalties(i) = k * log(n);
    
    % 综合评分 - 更新为与findOptimalIMFNumber.m相同的公式
    combinedScores(i) = residualEnergies(i) + orthogonalityScores(i) * 10 + imfValidityScores(i) * 5 + complexityPenalties(i) * 2e4;
end

% 只保留实际计算的部分
kValues = kValues(1:lastIdx);
residualEnergies = residualEnergies(1:lastIdx);
orthogonalityScores = orthogonalityScores(1:lastIdx);
imfValidityScores = imfValidityScores(1:lastIdx);
complexityPenalties = complexityPenalties(1:lastIdx);
combinedScores = combinedScores(1:lastIdx);

% 归一化所有得分，便于比较
residualEnergies_norm = residualEnergies / max(residualEnergies);
orthogonalityScores_norm = orthogonalityScores / max(orthogonalityScores);
imfValidityScores_norm = imfValidityScores / max(imfValidityScores);
complexityPenalties_norm = complexityPenalties / max(complexityPenalties);
combinedScores_norm = combinedScores / max(combinedScores);

% 创建图形
figure('Name', 'VMD评分组成分析', 'NumberTitle', 'off', 'Position', [100, 100, 1000, 800]);

% 绘制主图：各组成部分和综合评分 (归一化)
subplot(3, 1, 1);
hold on;
plot(kValues, residualEnergies_norm, 'r-o', 'LineWidth', 2, 'DisplayName', '残差能量');
plot(kValues, orthogonalityScores_norm, 'g-s', 'LineWidth', 2, 'DisplayName', '正交性评分');
plot(kValues, imfValidityScores_norm, 'b-^', 'LineWidth', 2, 'DisplayName', 'IMF有效性评分');
plot(kValues, complexityPenalties_norm, 'm-d', 'LineWidth', 2, 'DisplayName', '复杂度惩罚');
plot(kValues, combinedScores_norm, 'k-*', 'LineWidth', 2, 'DisplayName', '综合评分');
hold off;

% 找到最佳K值
[~, bestIdx] = min(combinedScores);
bestK = kValues(bestIdx);

% 标记最佳K值
hold on;
plot(bestK, combinedScores_norm(bestIdx), 'mo', 'MarkerSize', 12, 'LineWidth', 2);
text(bestK, combinedScores_norm(bestIdx), [' 最佳K = ', num2str(bestK)], 'VerticalAlignment', 'bottom');
hold off;

title('VMD不同K值下各评分组成 (归一化)', 'FontSize', 14);
xlabel('IMF数量 (K)', 'FontSize', 12);
ylabel('归一化评分', 'FontSize', 12);
grid on;
legend('Location', 'best');
xlim([min(kValues)-0.5, max(kValues)+0.5]);
xticks(kValues);

% 绘制原始评分 (非归一化)
subplot(3, 1, 2);
hold on;
yyaxis left
plot(kValues, residualEnergies, 'r-o', 'LineWidth', 2, 'DisplayName', '残差能量');
ylabel('残差能量', 'FontSize', 12, 'Color', 'r');

yyaxis right
plot(kValues, orthogonalityScores, 'g-s', 'LineWidth', 2, 'DisplayName', '正交性评分');
plot(kValues, imfValidityScores, 'b-^', 'LineWidth', 2, 'DisplayName', 'IMF有效性评分');
plot(kValues, complexityPenalties, 'm-d', 'LineWidth', 2, 'DisplayName', '复杂度惩罚');
ylabel('其他评分', 'FontSize', 12);
hold off;

title('VMD不同K值下各评分组成 (原始值)', 'FontSize', 14);
xlabel('IMF数量 (K)', 'FontSize', 12);
grid on;
legend('Location', 'best');
xlim([min(kValues)-0.5, max(kValues)+0.5]);
xticks(kValues);

% 绘制堆叠柱状图：各组成部分对综合评分的贡献
subplot(3, 1, 3);
% 重新计算各部分对最终评分的贡献
residualContrib = residualEnergies / max(combinedScores);
orthogonalityContrib = orthogonalityScores * 10 / max(combinedScores);
validityContrib = imfValidityScores * 5 / max(combinedScores);
complexityContrib = complexityPenalties * 2e4 / max(combinedScores);

% 创建堆叠数据
stackData = [residualContrib, orthogonalityContrib, validityContrib, complexityContrib];
bar(kValues, stackData, 'stacked');

% 高亮最佳K值
hold on;
barColors = get(gca, 'Children');
for i = 1:length(barColors)
    xdata = get(barColors(i), 'XData');
    ydata = get(barColors(i), 'YData');
    for j = 1:length(xdata)/4
        idx = (j-1)*4 + 1;
        if xdata(idx) == bestK
            % 计算对应的边界位置
            patch([xdata(idx), xdata(idx+1), xdata(idx+2), xdata(idx+3)], [ydata(idx), ydata(idx+1), ydata(idx+2), ydata(idx+3)], 'red', 'FaceAlpha', 0.1, 'EdgeColor', 'red', 'LineWidth', 1.5);
        end
    end
end
hold off;

title('VMD评分组成贡献分析', 'FontSize', 14);
xlabel('IMF数量 (K)', 'FontSize', 12);
ylabel('评分贡献', 'FontSize', 12);
grid on;
legend('残差能量贡献', '正交性贡献(×10)', 'IMF有效性贡献(×5)', '复杂度惩罚(×2e4)', 'Location', 'best');
xlim([min(kValues)-0.5, max(kValues)+0.5]);
xticks(kValues);

% 添加标注
annotation('textbox', [0.5, 0.01, 0, 0], 'String', sprintf('最佳K = %d', bestK), ...
    'HorizontalAlignment', 'center', 'FontSize', 12, 'FitBoxToText', 'on');

% 保存分析结果
saveas(gcf, 'VMD_Score_Components_Analysis.png');
saveas(gcf, 'VMD_Score_Components_Analysis.fig');

% 输出结果并保存数据
fprintf('最佳K值: %d\n', bestK);
fprintf('VMD评分组成分析图已保存为 VMD_Score_Components_Analysis.png 和 VMD_Score_Components_Analysis.fig\n');

% 保存详细数据供后续分析
scoreData = table(kValues', residualEnergies, orthogonalityScores, imfValidityScores, complexityPenalties, combinedScores, ...
    'VariableNames', {'K', 'ResidualEnergy', 'OrthogonalityScore', 'IMFValidityScore', 'ComplexityPenalty', 'CombinedScore'});
save('VMD_Score_Components_Data.mat', 'scoreData', 'bestK');
writetable(scoreData, 'VMD_Score_Components.csv');
fprintf('评分组成数据已保存为 VMD_Score_Components_Data.mat 和 VMD_Score_Components.csv\n');

end 