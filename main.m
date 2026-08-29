%%%****************************************************************************************
%%%* This is the source code for the paper "Multi-step-ahead Stock Price Prediction Using *
%%%* Recurrent Fuzzy Neural Network and Variational Mode Decomposition" (VMD-MFRFFN)      *  
%%%* Authors: Hamid Nasiri, Mohammad Mehdi Ebadzadeh                                      *
%%%* Modified: Using original AO (Aquila Optimizer) implementation                        *
%%%* Modified: Added adaptive IMF number selection based on MEMD principles               *
%%%* Modified: Added visualization of K value selection process                           *
%%%****************************************************************************************

% 记录开始时间
tic;

rng(1); % For reproducibility of results

global nStates;
global nData;
global nRules_Output;
global rbarOutput;
global rbarState;
global currentIndividual;
global targetOutput;


%% Load HSI Benchmark
fprintf("Loading SSE Index Dataset...\n");
maxNumberOfIMFS = 15; % 增加上限以便更灵活地确定最佳K值
TargetDimension = 1;
load('Benchmarks\\SSE_Index.mat');
% Test Data
testOutputTemp = data(end-375:end,TargetDimension);

% Train Data
data = data(1:end-377,TargetDimension);

finalPrediction = [];

% 使用自适应方法确定最佳K值，并启用绘图功能
fprintf("Finding optimal number of IMFs using MEMD-based criteria...\n");
[optimalK, kScores] = findOptimalIMFNumber(data, maxNumberOfIMFS, true);
fprintf("Determined optimal number of IMFs: %d\n", optimalK);

% 保存评分数据供后续分析
save('VMD_K_Scores.mat', 'kScores', 'optimalK');

% 可视化不同K值下的VMD分解结果
fprintf("Visualizing VMD decomposition with different K values...\n");
% 选择要比较的K值，包括自动确定的最佳K值和其他几个参考K值
kValuesToCompare = sort(unique([max(2, optimalK-2), optimalK, min(optimalK+2, maxNumberOfIMFS)]));
visualizeVMDDecomposition(data, kValuesToCompare);

% 分析和可视化评分组成
fprintf("Analyzing score components for different K values...\n");
analyzeScoreComponents(data, maxNumberOfIMFS);

% 生成并保存VMD各分量的单独图像
fprintf("Generating and saving individual VMD component plots...\n");
saveVMDComponents(data, optimalK, 'SSE_Index', 'VMD_Components_Figures');

fprintf("Decomposing Train Data Using VMD with optimal K=%d...\n", optimalK);
[imf,residual] = vmd(data,'NumIMF',optimalK);
fprintf("Decomposing Test Data Using VMD with optimal K=%d...\n", optimalK);
[imf_test, residual_test] = vmd(testOutputTemp,'NumIMF',optimalK);

% 动态调整规则数量以适应不同数量的IMF
numberOfRules = ones(1, optimalK) * 6; % 初始设置
for i = 1:optimalK
    if i > 6
        numberOfRules(i) = 4; % 复杂度较低的IMF使用较少的规则
    elseif i > 3
        numberOfRules(i) = 5; % 中等复杂度的IMF使用中等数量的规则
    else
        numberOfRules(i) = 6; % 复杂度较高的IMF使用较多的规则
    end
end

for numberOfIMFS = 1:optimalK

    data = imf(:,numberOfIMFS);
    data_test = imf_test(:,numberOfIMFS);
    
    tempdata = data;
    tempdata_test = data_test;
    data = (data - min(data)) ./ (max(data)-min(data)) ;
    data_test = (data_test - min(data_test)) ./ (max(data_test)-min(data_test)) ;

    trainInput = data(1:end-1,TargetDimension);
    targetOutput = data(2:end,TargetDimension);
    testInput = data_test(1:end-1,TargetDimension);
    testOutput = data_test(2:end,TargetDimension);


    % ****************************************************
    % *                  Parameters                      *
    % ****************************************************

    coverageRules = false; % Generating Fuzzy Rules Using Coverage?
    ruleSigma = 0.3;
    coverageThreshold = 0.2;
    nRules_Output = numberOfRules(numberOfIMFS);
    nRules_State = 2;
    nStates = 2;
    mfType = "trimf"; % trimf gaussmf gauss2mf gbellmf 
    nFuzzySetsOutput = numberOfRules(numberOfIMFS);
    nFuzzySetsState = 2;
    nData = size(trainInput,1);
    nDimensions = size(trainInput,2);

    %% Create Fuzzy Rules
    if ~coverageRules
        if mfType == "gaussmf" 
            mfOutput = createGaussianMembershipFunction(nFuzzySetsOutput);
            mfState = createGaussianMembershipFunction(nFuzzySetsState);
        elseif mfType == "trimf"
            mfOutput = createMembershipFunction(nFuzzySetsOutput);
            mfState = createMembershipFunction(nFuzzySetsState);
        elseif mfType == "gauss2mf"
            mfOutput = createGaussian2MembershipFunction(nFuzzySetsOutput);
            mfState = createGaussian2MembershipFunction(nFuzzySetsState);
        elseif mfType == "gbellmf"
            mfOutput = createGeneralizedBellshapeMembershipfunction(nFuzzySetsOutput);
            mfState = createGeneralizedBellshapeMembershipfunction(nFuzzySetsState);    
        end
        mfOutput = repmat(mfOutput,1,nDimensions);
        mfState = repmat(mfState,1,nDimensions);
    else
        if ~exist('mf','var')
            if mfType == "gaussmf"
                generateGaussianFuzzyRulesUsingCoverage;
            elseif mfType == "trimf"
                generateTriangleFuzzyRulesUsingCoverage;
            end
        end
        mfOutput = mf;
        mfState = mf;
        nFuzzySetsOutput = length(mf);
        nFuzzySetsState = length(mf);

        nRules_Output = nFuzzySetsOutput;
        nRules_State = nFuzzySetsState;
    end

    fprintf("Calculating Membership Values...\n");
    calculateMembershipValues;


    %% Initialization

    % W -> Weight of Output Network
    % V -> Weight of State Network
    currentIndividual.V = rand(nStates,nRules_State);
    currentIndividual.W = rand(nStates,nRules_Output);
    costCalculation;

    %% Training Network

    fprintf("Training Network Using AO For IMF%d ...",numberOfIMFS); 

    fun = @(x) objectiveFunction(x);
    lb = zeros(1,nRules_State*nStates);
    ub = ones(1,nRules_State*nStates);
    AO_SwarmSize = 20;  % 种群大小
    AO_MaxIteration = 50;  % 最大迭代次数
    
    [Best_FF, Best_P, conv] = AO(AO_SwarmSize, AO_MaxIteration, lb, ub, nRules_State*nStates, fun);
    
    currentIndividual.V = Best_P;   
    costCalculation   
    calculatingTestError;

    finalPrediction = [finalPrediction ; scaledPredicted'];

end

predictedOutput = sum(finalPrediction);

predictedOutput = predictedOutput';
actualValues = testOutputTemp(2:end);
predictedValues = predictedOutput;

% 计算各项评价指标
testRMSE = sqrt(immse(predictedValues, actualValues));  % 均方根误差
testMAPE = mean(abs((actualValues - predictedValues) ./ actualValues) * 100);  % 平均绝对百分比误差
testMAE = mean(abs(actualValues - predictedValues));  % 平均绝对误差

% 计算决定系数 R²
SS_res = sum((actualValues - predictedValues).^2);  % 残差平方和
SS_tot = sum((actualValues - mean(actualValues)).^2);  % 总平方和
testR2 = 1 - (SS_res / SS_tot);  % 决定系数

fprintf("One-step-ahead Prediction Results:\n");
fprintf("RMSE = %e\n",testRMSE);
fprintf("MAE = %e\n",testMAE);
fprintf("MAPE = %e\n",testMAPE);
fprintf("R² (决定系数) = %.6f\n",testR2);

% 计算并输出总运行时间
totalTime = toc;
fprintf("\n总运行时间: %.2f 秒\n", totalTime);
