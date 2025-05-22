function V = IDWR(x,y,v,X,Y,K)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% 散点数据曲面插值，反距离加权回归(Inverse distance weighted regression，IDWR)算法
% 输入：
%   x,y,v--散点数据向量
%   X,Y--为未知点坐标向量,或矩阵
%   K--参与加权运算的点的数量
% 输出：V--未知点的值向量或矩阵
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%%
%N = length(x);  % 散点个数
M = numel(X); % 未知点个数
%d = zeros(N,1); % 各散点(xi,yi)到未知点(Xj,Yj)的距离
%w = d; % 各散点(xi,yi)对未知点(Xj,Yj)的权重
V = zeros(size(X)); % 未知点的z值，Z(X,Y)
%%
epsilon = 1e-5; % 用于与0作比较的误差
for j = 1:M  % 循环所有未知点
    % 计算各散点(xi,yi)到未知点(Xj,Yj)的距离
    dx = x-X(j);  dy = y-Y(j);
    % dist = sqrt(dx.*dx+dy.*dy);
    dist = (dx.^2+dy.^2);  % 距离的平方
    % 找到K个距离最短的点
    [dist,IX] = sort(dist,'ascend'); % 升序排列
    d = dist(1:K);  % IX(1:K)为这K个点在样本序列中的编号向量  
    if(any(d)<=epsilon) % 特殊点处理
        V(j) = v(IX(1));
    else
        w = 1./d; %  计算各这K个点对未知点(Xj,Yj)的权重
        D = sum(w); % 权重和
        y_IDW = sum(w.*v(IX(1:K)))/D;% 计算未知点的IDW值
        V(j) = y_IDW + K*(sum(v(IX(1:K))) - K*y_IDW )/ (K^2 - sum(d)*D);
    end
end
end
