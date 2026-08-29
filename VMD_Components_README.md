# VMD分量图像生成说明

## 功能概述

本项目新增了自动生成VMD分解后各个分量图像的功能，可以为每个数据集单独输出：
- 原始时间序列图像
- 各个IMF分量图像（IMF1, IMF2, ..., IMFk）
- 残差图像

## 文件说明

### 核心函数
- **`saveVMDComponents.m`**: 核心函数，为单个数据集生成所有VMD分量图像
  - 输入参数：
    - `signal`: 原始信号数据
    - `optimalK`: 最优K值（IMF数量）
    - `datasetName`: 数据集名称（如 'HSI_Index'）
    - `outputFolder`: 输出文件夹（可选，默认为 'VMD_Components_Figures'）

### 批处理脚本
- **`generateAllVMDComponentsPlots.m`**: 为所有三个数据集批量生成VMD分量图像
  - 处理的数据集：
    - HSI_Index (恒生指数)
    - SSE_Index (上证指数)
    - SandP_Index (标普指数)

### 主程序集成
- **`main.m`**: 已在第57行添加自动调用功能，运行主程序时会自动生成SSE_Index的VMD分量图

## 使用方法

### 方法1：运行主程序（推荐）
直接运行 `main.m`，程序会在确定最优K值后自动生成SSE_Index的VMD分量图像。

```matlab
main
```

### 方法2：批量生成所有数据集图像
单独运行批处理脚本，为所有三个数据集生成图像：

```matlab
generateAllVMDComponentsPlots
```

### 方法3：为单个数据集生成图像
手动调用核心函数：

```matlab
% 加载数据
load('Benchmarks\HSI_Index.mat');
signal = data(:, 1);

% 设置最优K值（根据实际情况调整）
optimalK = 13;

% 生成并保存图像
saveVMDComponents(signal, optimalK, 'HSI_Index', 'VMD_Components_Figures');
```

## 输出结构

生成的图像将保存在以下目录结构中：

```
VMD_Components_Figures/
├── HSI_Index/
│   ├── HSI_Index_Original.png  (原始序列)
│   ├── IMF1.png
│   ├── IMF2.png
│   ├── ...
│   ├── IMF13.png
│   └── Residual.png
├── SSE_Index/
│   ├── SSE_Index_Original.png
│   ├── IMF1.png
│   └── ...
└── SandP_Index/
    ├── SandP_Index_Original.png
    ├── IMF1.png
    └── ...
```

## 修改最优K值

如果需要修改各数据集的最优K值，请编辑 `generateAllVMDComponentsPlots.m` 文件中的 `datasets` 变量：

```matlab
datasets = {
    'HSI_Index', 13;   % 数据集名称, 最优K值
    'SSE_Index', 13;   % 根据实际情况调整K值
    'SandP_Index', 13  % 根据实际情况调整K值
};
```

## 图像格式

- 所有图像默认以PNG格式保存
- 图像尺寸：800x300像素
- 支持标准MATLAB图形格式（可在 `saveVMDComponents.m` 中修改）

## 注意事项

1. 确保MATLAB安装了信号处理工具箱（Signal Processing Toolbox），其中包含 `vmd` 函数
2. 首次运行时会自动创建输出文件夹
3. 如果文件已存在，会被自动覆盖
4. 生成图像时使用 `'Visible', 'off'` 参数以加快处理速度

## 常见问题

**Q: 如何修改图像样式？**
A: 编辑 `saveVMDComponents.m` 中的绘图参数，如线条颜色、宽度、标题等。

**Q: 如何添加新的数据集？**
A: 在 `generateAllVMDComponentsPlots.m` 的 `datasets` 数组中添加新条目。

**Q: 如何更改输出文件夹？**
A: 修改函数调用时的 `outputFolder` 参数，或在 `generateAllVMDComponentsPlots.m` 中修改默认值。
