*Title: An Adaptive Neuro-fuzzy Framework for Stock Price Forecasting

*Authors:Pengju Ren,Chengbin Peng,Baisong Liu,Xiaoqin Fan(https://github.com/renpengju-ai/ANF)

*Abstract: Accurate stock price prediction is severely hindered by the extreme 
non-stationarity and complex regime-switching behaviors of financial time se
ries.Existing hybrid models typically face three major bottlenecks.These include 
signal decomposition parameters,which rely heavily on prior experience,meta
heuristic optimization algorithms are prone to premature convergence in high
dimensional spaces,and models lack adaptive perception of dynamic market 
states.To address these limitations,this paper proposes an Adaptive Neuro-fuzzy 
Framework.This framework makes three main contributions.First,a multi-cri
teria mode determination mechanism is constructed to achieve data-driven opti
mal parameter selection for variational mode decomposition.Second,an En
hanced Aquila Optimizer incorporating a Dynamic Parameter Scheduling strat
egy is developed,utilizing an iteration-driven dynamic mechanism to effectively 
prevent premature convergence during parameter tuning.Finally,a Heuristic
Driven State Optimization mechanism is designed for the Multi-Functional Re
current Fuzzy Neural Network.By exclusively deploying the proposed optimizer 
to navigate the non-convex state space,this mechanism explicitly models market 
regime dynamics.It explicitly deploys the proposed Enhanced Aquila Optimizer 
to optimize the non-convex state space,effectively preventing premature conver
gence.Experimental results on the Hang Seng Index,Shanghai Stock Exchange 
Composite Index,and Standard &Poor's 500 show that this framework achieves 
a significant breakthrough,reducing the average Root Mean Square Error by
74.8%compared to the baseline Long Short-Term Memory model.This study 
provides a high-precision and adaptive technical paradigm for complex financial 
time series analysis.


## Source Code and Dataset

To run the code simply execute `main.m`

**Datasets:** 
The [`Benchmarks`](Benchmarks/) folder contains three financial time series datasets used for testing and evaluating the code.

+ `HSI_Index.mat` corresponds to HSI time series.
+ `SSE_Index.mat` corresponds to the SSE time series.
+ `SandP_Index.mat` corresponds to the SPX time series.

