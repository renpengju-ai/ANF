%%%****************************************************************************************
%%%* 为所有数据集生成VMD分解后的各个分量图像
%%%* 包括：原始序列、各个IMF分量、残差
%%%****************************************************************************************

clear; clc;

fprintf('==================================================================\n');
fprintf('为所有数据集生成VMD分解分量图像\n');
fprintf('==================================================================\n\n');

% 定义数据集信息
datasets = {
    'HSI_Index', 13;   % 数据集名称, 最优K值
    'SSE_Index', 9;   % 根据实际情况调整K值
    'SandP_Index', 13  % 根据实际情况调整K值
};

% 输出文件夹
outputFolder = 'VMD_Components_Figures';

% 为每个数据集生成图像
for i = 1:size(datasets, 1)
    datasetName = datasets{i, 1};
    optimalK = datasets{i, 2};
    
    fprintf('------------------------------------------------------------------\n');
    fprintf('处理数据集: %s (最优K值=%d)\n', datasetName, optimalK);
    fprintf('------------------------------------------------------------------\n');
    
    % 加载数据
    try
        dataFile = fullfile('Benchmarks', [datasetName '.mat']);
        loadedData = load(dataFile);
        
        % 获取数据（假设数据存储在变量 'data' 中）
        if isfield(loadedData, 'data')
            signal = loadedData.data(:, 1);  % 使用第一列数据
        else
            % 如果字段名不是 'data'，尝试获取第一个变量
            fields = fieldnames(loadedData);
            signal = loadedData.(fields{1});
            if size(signal, 2) > 1
                signal = signal(:, 1);
            end
        end
        
        fprintf('成功加载数据，信号长度: %d\n', length(signal));
        
        % 生成并保存VMD分量图像
        saveVMDComponents(signal, optimalK, datasetName, outputFolder);
        
    catch ME
        fprintf('处理 %s 时出错: %s\n', datasetName, ME.message);
        fprintf('错误位置: %s (行 %d)\n', ME.stack(1).name, ME.stack(1).line);
        continue;
    end
end

fprintf('==================================================================\n');
fprintf('所有数据集处理完成！\n');
fprintf('图像保存在文件夹: %s\n', outputFolder);
fprintf('==================================================================\n');
