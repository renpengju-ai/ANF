# ANF

## Introduction


*Authors:* [ren pengju/Peng Chengbin]([https://www.linkedin.com/in/hamid-nasiri-b5555487]

*Abstract:* Financial markets play a crucial role in capital allocation and risk diversification in the modern economy. However, financial time series inherently exhibit extreme volatility, non-stationarity, and complex regime-switching characteristics. Existing mainstream deep learning models, such as long short-term memory networks and self-attention architectures, generally tend to construct global static mappings, making it difficult to explicitly characterize the dynamic patterns of frequent market regime transitions, and they lack the semantic transparency essential for quantitative decision-making. Furthermore, the prevalent decomposition-prediction hybrid modeling paradigm still faces several limitations. In univariate forecasting, signal decomposition techniques heavily rely on subjective experience for parameter setting, and complex neuro-fuzzy systems are prone to premature convergence when optimizing in high-dimensional non-convex state spaces. Independent decomposition of multi-dimensional volume-price heterogeneous data easily triggers the mode misalignment dilemma, while direct homogeneous concatenation of high-dimensional features inevitably leads to the severe curse of dimensionality.
To address the aforementioned technical bottlenecks, this thesis constructs a multi-stage quantitative forecasting framework encompassing underlying feature decoupling, high-dimensional parameter adaptive optimization, and multi-scale collaborative inference, proposing two adaptive neuro-fuzzy prediction algorithmic models respectively. The main innovative contributions are as follows:
1. An adaptive univariate prediction model based on adaptive feature decoupling and neuro-fuzzy inference is proposed. Addressing the strong non-stationarity of univariate time series, a univariate adaptive decoupling strategy is constructed, achieving automatic data-driven selection of optimal decomposition parameters through a multi-criteria mode determination mechanism. Second, an Enhanced Aquila Optimizer (EAO) integrating dual dynamic scheduling strategies is developed. Through iteration-driven linear scheduling and population diversity response feedback mechanisms, the premature convergence problem in complex model optimization is successfully resolved. Finally, a heuristic state optimization mechanism is designed for the Multi-Functional Recurrent Fuzzy Neural Network (MFRFNN) to better capture market state features. Experimental results show that this univariate model significantly outperforms traditional deep learning baseline architectures in prediction accuracy, achieving a substantial average reduction of approximately 74.7% in root mean square error (RMSE).

This repository contains MATLAB source code of the following paper:
([https://www.sciencedirect.com/science/article/abs/pii/S1568494623008852](https://scholar.google.com/scholar?q=An+Adaptive+Neuro-fuzzy+Framework+for+Stock+Price+Forecasting.))

## Source Code and Dataset

To run the code simply execute `main.m`

**Datasets:** 
The [`Benchmarks`](Benchmarks/) folder contains three financial time series datasets used for testing and evaluating the code.

+ `HSI_Index.mat` corresponds to HSI time series.
+ `SSE_Index.mat` corresponds to the SSE time series.
+ `SandP_Index.mat` corresponds to the SPX time series.



## Contact Me

If you have any questions, do not hesitate to reach me via [Linkedin](https://www.linkedin.com/in/hamid-nasiri-b5555487/) or email: h.nasiri@aut.ac.ir

Thank you so much for your attention.
