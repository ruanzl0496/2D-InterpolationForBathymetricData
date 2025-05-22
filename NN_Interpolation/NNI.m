% 最邻近插值
% 主要思想：从点(x,y)周围找一个最近的点，该点的值就作为(x，y)点的值。
function vq = NNI(x,y,v,xq,yq)
    % 使 v = f(x,y) 形式的曲面与向量 (x,y,v) 中的散点数据拟合,该函数在 (xq,yq) 指定的查询点对曲面进行插值并返回插入的值 vq
    % 已知数据点：x,y,v--向量，
    % 待插值的数点：xq,yq--向量或矩阵
    % 返回插值结果：vq--向量或矩阵

    xqLen = numel(xq); % xq元素个数
    xLen = numel(x); % x元素个数
    vq = zeros(size(xq));
    
    for i = 1:xqLen  % 对每一点（xqi,yqi）都循环插值
        %% step 1: 找到离(xqi,yqi)最近的一个点
        % dist = sqrt((xq(i)-x).^2 + (yq(i)-y).^2);  %
        % 计算(xqi,yqi)到各已知点的距离,实际不必开根号
        dist = (xq(i)-x).^2 + (yq(i)-y).^2;  % 计算(xqi,yqi)到各已知点的距离
        dist_min = dist(1);
        k = 1; % dist中最小元素的索引
        for j = 2:xLen
            if(dist(j)<dist_min)
                dist_min = dist(j);
                k = j;
            end
        end
        vq(i) = v(k);
    end

end
