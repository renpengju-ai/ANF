function [Best_FF,Best_P,conv]=AO(N,T,LB,UB,Dim,F_obj)
%_______________________________________________________________________________________%
%  Aquila Optimizer (AO) source codes (version 1.0)                                     %
%                                                                                       %
%  Developed in MATLAB R2015a (7.13)                                                    %
%  Author and programmer:                                                               %
%  Abualigah, L, Yousri, D, Abd Elaziz, M, Ewees, A, Al-qaness, M, Gandomi, A.          %
%         e-Mail: Aligah.2020@gmail.com      (Laith Abualigah)                          %
%       Homepage:                                                                       %
%         1- https://scholar.google.com/citations?user=39g8fyoAAAAJ&hl=en               %
%         2- https://www.researchgate.net/profile/Laith_Abualigah                       %
%                                                                                       %
%   Main paper:                                                                         %
%_____________Aquila Optimizer: A novel meta-heuristic optimization algorithm___________%
%_______________________________________________________________________________________%

Best_P=zeros(1,Dim);
Best_FF=inf;

% 初始化种群
X=initialization(N,Dim,UB,LB);
Xnew=X;
Ffun=zeros(1,size(X,1));
Ffun_new=zeros(1,size(Xnew,1));

t=1;

% 自适应参数控制
alpha_max = 0.5;  % alpha的最大值
alpha_min = 0.1;  % alpha的最小值
delta_max = 0.5;  % delta的最大值
delta_min = 0.1;  % delta的最小值

while t<T+1
    % 计算当前迭代的自适应参数
    alpha = alpha_max - (alpha_max - alpha_min) * (t/T);  % 随着迭代进行，alpha逐渐减小
    delta = delta_min + (delta_max - delta_min) * (t/T);  % 随着迭代进行，delta逐渐增大
    
    % 计算种群多样性
    pop_diversity = mean(std(X));  % 使用种群标准差作为多样性指标
    
    % 根据种群多样性调整参数
    if pop_diversity < 0.1  % 如果种群多样性较低
        alpha = min(alpha * 1.2, alpha_max);  % 增加alpha以增强探索
        delta = max(delta * 0.8, delta_min);  % 减小delta以减弱扰动
    end
    
    for i=1:size(X,1)
        F_UB=X(i,:)>UB;
        F_LB=X(i,:)<LB;
        X(i,:)=(X(i,:).*(~(F_UB+F_LB)))+UB.*F_UB+LB.*F_LB;
        Ffun(1,i)=F_obj(X(i,:));
        if Ffun(1,i)<Best_FF
            Best_FF=Ffun(1,i);
            Best_P=X(i,:);
        end
    end
    
    G2=2*rand()-1; % Eq. (16)
    G1=2*(1-(t/T));  % Eq. (17)
    to = 1:Dim;
    u = .0265;
    r0 = 10;
    r = r0 +u*to;
    omega = .005;
    phi0 = 3*pi/2;
    phi = -omega*to+phi0;
    x = r .* sin(phi);  % Eq. (9)
    y = r .* cos(phi); % Eq. (10)
    QF=t^((2*rand()-1)/(1-T)^2); % Eq. (15)
    
    for i=1:size(X,1)
        if t<=(2/3)*T
            if rand <0.5
                Xnew(i,:)=Best_P(1,:)*(1-t/T)+(mean(X(i,:))-Best_P(1,:))*rand(); % Eq. (3) and Eq. (4)
                Ffun_new(1,i)=F_obj(Xnew(i,:));
                if Ffun_new(1,i)<Ffun(1,i)
                    X(i,:)=Xnew(i,:);
                    Ffun(1,i)=Ffun_new(1,i);
                end
            else
                Xnew(i,:)=Best_P(1,:).*Levy(Dim)+X((floor(N*rand()+1)),:)+(y-x)*rand;       % Eq. (5)
                Ffun_new(1,i)=F_obj(Xnew(i,:));
                if Ffun_new(1,i)<Ffun(1,i)
                    X(i,:)=Xnew(i,:);
                    Ffun(1,i)=Ffun_new(1,i);
                end
            end
        else
            if rand<0.5
                Xnew(i,:)=(Best_P(1,:)-mean(X))*alpha-rand+((UB-LB)*rand+LB)*delta;   % Eq. (13)
                Ffun_new(1,i)=F_obj(Xnew(i,:));
                if Ffun_new(1,i)<Ffun(1,i)
                    X(i,:)=Xnew(i,:);
                    Ffun(1,i)=Ffun_new(1,i);
                end
            else
                Xnew(i,:)=QF*Best_P(1,:)-(G2*X(i,:)*rand)-G1.*Levy(Dim)+rand*G2; % Eq. (14)
                Ffun_new(1,i)=F_obj(Xnew(i,:));
                if Ffun_new(1,i)<Ffun(1,i)
                    X(i,:)=Xnew(i,:);
                    Ffun(1,i)=Ffun_new(1,i);
                end
            end
        end
    end
    
    if mod(t,10)==0
        fprintf('Iteration %d: Best fitness = %e\n', t, Best_FF);
    end
    conv(t)=Best_FF;
    t=t+1;
end
end

function o=Levy(d)
beta=1.5;
sigma=(gamma(1+beta)*sin(pi*beta/2)/(gamma((1+beta)/2)*beta*2^((beta-1)/2)))^(1/beta);
u=randn(1,d)*sigma;v=randn(1,d);step=u./abs(v).^(1/beta);
o=step;
end

function X=initialization(N,Dim,UB,LB)
    % 初始化函数
    % 输入:
    %   N: 种群大小
    %   Dim: 问题维度
    %   UB: 上界向量
    %   LB: 下界向量
    % 输出:
    %   X: 初始化后的种群
    
    % 检查边界数量
    B_no = size(UB,2);
    
    % 如果每个变量都有不同的上下界
    if B_no > 1
        for i = 1:Dim
            Ub_i = UB(i);
            Lb_i = LB(i);
            X(:,i) = rand(N,1).*(Ub_i-Lb_i)+Lb_i;
        end
    else
        % 如果所有变量共享相同的边界
        X = rand(N,Dim).*(UB-LB)+LB;
    end
end 