# An Adaptive Neuro-fuzzy Framework for Stock Price Forecasting

This repository is the **improved and extended version** based on the existing VMD-MFRFNN stock forecasting framework. It corresponds to the ICIC 2026 conference paper published in *Lecture Notes in Computer Science (LNCS 16648)*.

## Abstract:
 Accurate stock price prediction is severely hindered by the extreme non-stationarity and complex regime-switching behaviors of financial time series.Existing hybrid models typically face three major bottlenecks.These include signal decomposition parameters,which rely heavily on prior experience,meta heuristic optimization algorithms are prone to premature convergence in high dimensional spaces,and models lack adaptive perception of dynamic market states.To address these limitations,this paper proposes an Adaptive Neuro-fuzzy Framework.This framework makes three main contributions.First,a multi-criteria mode determination mechanism is constructed to achieve data-driven optimal parameter selection for variational mode decomposition.Second,an Enhanced Aquila Optimizer incorporating a Dynamic Parameter Scheduling strategy is developed,utilizing an iteration-driven dynamic mechanism to effectively prevent premature convergence during parameter tuning.Finally,a Heuristic Driven State Optimization mechanism is designed for the Multi-Functional Recurrent Fuzzy Neural Network.By exclusively deploying the proposed optimizer to navigate the non-convex state space,this mechanism explicitly models market regime dynamics.It explicitly deploys the proposed Enhanced Aquila Optimizer to optimize the non-convex state space,effectively preventing premature convergence.Experimental results on the Hang Seng Index,Shanghai Stock Exchange Composite Index,and Standard &Poor's 500 show that this framework achieves a significant breakthrough,reducing the average Root Mean Square Error by 74.8%compared to the baseline Long Short-Term Memory model.This study provides a high-precision and adaptive technical paradigm for complex financial time series analysis.


## Environment Requirements

- MATLAB R2022b or higher

## Quick Start

Run the main program directly in MATLAB:

```Plain Text
main.m
```

## Dataset Description

All experimental datasets are placed in the `Benchmarks` folder, covering three typical global stock indices:

- `HSI_Index.mat`: Hang Seng Index time series

- `SSE_Index.mat`: Shanghai Stock Exchange Composite Index time series

- `SandP_Index.mat`: S &P 500 Index time series


## Citation

If you find this repository or framework helpful in your research, please cite our paper::


```Plain Text
@inproceedings{ren2026adaptive,
  title     = {An Adaptive Neuro-fuzzy Framework for Stock Price Forecasting},
  author    = {Ren, Pengju and Peng, Chengbin and Liu, Baisong and Fan, Xiaoqin},
  booktitle = {International Conference on Intelligent Computing (ICIC)},
  series    = {Lecture Notes in Computer Science},
  volume    = {16648},
  year      = {2026},
  publisher = {Springer}
}
```

## Acknowledgements& References

This implementation builds upon concepts from decomposition-based fuzzy neural frameworks. We gratefully acknowledge the foundational open-source contributions of Nasiri & Ebadzadeh (2023):

```Plain Text
@article{nasiri2023multi,
  title   = {Multi-step-ahead stock price prediction using recurrent fuzzy neural network and variational mode decomposition},
  author  = {Nasiri, Hamid and Ebadzadeh, Mohammad Mehdi},
  journal = {Applied Soft Computing},
  pages   = {110867},
  year    = {2023}
}
```

