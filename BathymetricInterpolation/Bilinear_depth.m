function V = Bilinear_depth(x,y,z,X,Y)
    % 矩形网格水深数据插值，双线性算法
    % 已知数据点：x,y,v--均匀矩形网格点对应的数据向量，一行中x坐标是增加的，y坐标相同，但是第i行的y坐标大于第i+1行的y坐标，
    % 待插值的数点：X,Y--向量或矩阵
    % 返回插值结果：V--向量或矩阵

N = length(x);  % 散点个数
M = numel(X); % 未知点个数

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
    % 确定X(j),Y(j)在xRange和yRang中的前一个点的索引号,即该点周围的4个点
    IX1 = fix((X(j)-xRange(1))/DX)+1;
    IY1 = fix((Y(j)-yRange(1))/DY)+1;
    IX2 = min(IX1+1,n);
    IY2 = min(IY1+1,m);
    Q11 = [xRange(IX1),yRange(IY1),Z(IY1,IX1)]; % 左上角
    Q12 = [xRange(IX2),yRange(IY1),Z(IY1,IX2)]; % 右上角
    Q21 = [xRange(IX1),yRange(IY2),Z(IY2,IX1)]; % 左下角
    Q22 = [xRange(IX2),yRange(IY2),Z(IY2,IX2)]; % 右下角
       
    % 在x方向插值
    t1 = (X(j) - Q11(1))/DX; % DX = Q12(1)-Q11(1)
    T1 = Q11 + t1*(Q12-Q11);
    t2 = t1;
    T2 = Q21 + t2*(Q22-Q21);
    
    % 在y方向插值
    t = (Y(j)- T1(2))/DY; % DY = T2(2)-T1(2);
    V(j) = T1(3) + t*(T2(3)-T1(3));   
end
end