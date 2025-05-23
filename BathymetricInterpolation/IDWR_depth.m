function V = IDWR_depth(x,y,z,X,Y)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% 矩形网格水深数据插值，反距离加权回归（Inverse Distance Weighted Regression,IDWR）算法
% 输入：
%   x,y,v--均匀矩形网格点对应的数据向量，一行中x坐标是增加的，y坐标相同，但是第i行的y坐标大于第i+1行的y坐标
%   X,Y--为未知点坐标向量,或矩阵
%   K--参与加权运算的点的数量,这里就用4个点
% 输出：V--未知点的值向量或矩阵
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%%
N = length(x);  % 散点个数
M = numel(X); % 未知点个数
epsilon = 1e-5; % 用于与0作比较的误差

xRange = unique(x);% 递增
yRange = flip(unique(y));% 递减
DX = xRange(2)-xRange(1) ; % x坐标分辨率
DY = yRange(2)-yRange(1); % y坐标分辨率，一般与x相同，但是为负值
m = length(yRange); % 作为深度矩阵的行数
n = length(xRange); % 作为深度矩阵的列数
Z = transpose(reshape(z,[n,m])); % 深度矩阵
V = zeros(size(X)); % 未知点的z值，Z(X,Y)
%%
for j = 1:M  % 循环所有未知点
    % 确定X(j),Y(j)周围的若干点
    selectorX = (X(j)-2*DX<=xRange & xRange<=X(j)+2*DX); % 选择器，用于选取该点左右经纬度差不超过2DX的若干点
    selectorY = (Y(j)+2*DY<=yRange & yRange<=Y(j)-2*DY); % 选择器，用于选取该点上下经纬度差不超过2DY的若干点,注意DY是负值
    x1 = xRange(selectorX);
    y1 = yRange(selectorY); 
    Z1 = Z(selectorY,selectorX);
    X1 = repmat(x1,size(Z1,1),1);
    Y1 = repmat(y1',1,size(Z1,2));
        
    % 调用IDW函数计算未知点（X(j),Y(j)）的值
    K = numel(Z1);
    v = IDWR(X1(:),Y1(:),Z1(:),[X(j)],[Y(j)],K);  % 注意，这里查询点向量进含一个点（X(j),Y(j)）
    V(j) = v(1);
end
end
