% 双线性插值
% 主要思想：从点(x,y)周围4个最近的点(左上角P1,右上角P2,左下角P3,右下角P4)，对这些点的值分别在x方向和y方向进行线性插值，一共进行3次插值。
%           如果有一个点不存在，则该点赋值为nan
function vq = Bilinear(X,Y,V,xq,yq)
    % 使 v = f(x,y) 形式的曲面与向量 (X,Y,V) 中的散点数据拟合,该函数在 (xq,yq) 指定的查询点对曲面进行插值并返回插入的值 vq
    % 已知数据点：X,Y,V--向量，
    % 待插值的数点：xq,yq--向量或矩阵
    % 返回插值结果：vq--向量或矩阵

    xLen = numel(xq); % 元素个数
    vq = zeros(size(xq));

    for i = 1:xLen  % 对每一点（xqi,yqi）都循环插值
        %% step 1: 找到离(xqi,yqi)最近的4个点(左上角P1,右上角P2,左下角P3,右下角P4)
        selector_LT = (X<=xq(i) & Y>=yq(i)); % 左上方点选择条件
        selector_RT = (X>=xq(i) & Y>=yq(i)); % 右上方点选择条件
        selector_LB = (X<=xq(i) & Y<=yq(i)); % 左下方点选择条件
        selector_RB = (X>=xq(i) & Y<=yq(i)); % 右下方点选择条件
        if( (sum(selector_LT)==0 && sum(selector_RT)==0) || ...
            (sum(selector_LT)==0 && sum(selector_LB)==0) || ...  
            (sum(selector_LT)==0 && sum(selector_RB)==0) || ...
            (sum(selector_RT)==0 && sum(selector_LB)==0) || ...
            (sum(selector_RT)==0 && sum(selector_RB)==0) || ...
            (sum(selector_LB)==0 && sum(selector_RB)==0)) % 如果有某2个方位没有点
            vq(i) = nan;
            continue
        end
        
        P1 = [nan nan nan];
        if(sum(selector_LT)>0)
            X1 = X(selector_LT); Y1 = Y(selector_LT); V1 = V(selector_LT);  % 所有左上方的点
            dist = ((xq(i)-X1).^2 + (yq(i)-Y1).^2);  % 计算(xqi,yqi)到各已知点的距离
            k=1; dist_min = dist(k);
            for j=2:length(dist)
                if(dist(j)<dist_min) dist_min = dist(j); k = j; end
            end
            P1 = [X1(k),Y1(k),V1(k)]; % 最近的1个点
        end
        %[~,I] = sort(dist,'ascend'); % 升序排列距离。 备注：算法以后改进，不用全部排序，找到4个最小的即可
        % P1 = [X1(I(1)),Y1(I(1)),V1(I(1))]; % 最近的1个点
        
        P2 = [nan nan nan];
        if(sum(selector_RT)>0)
            X1 = X(selector_RT); Y1 = Y(selector_RT); V1 = V(selector_RT);  % 所有右上方的点
            dist = ((xq(i)-X1).^2 + (yq(i)-Y1).^2);  % 计算(xqi,yqi)到各已知点的距离
            k=1; dist_min = dist(k);
            for j=2:length(dist)
                if(dist(j)<dist_min) dist_min = dist(j); k = j; end
            end
            P2 = [X1(k),Y1(k),V1(k)]; % 最近的1个点
        end
        
        P3 = [nan nan nan];
        if(sum(selector_LB)>0)
            X1 = X(selector_LB); Y1 = Y(selector_LB); V1 = V(selector_LB);  % 所有左下方的点
            dist = ((xq(i)-X1).^2 + (yq(i)-Y1).^2);  % 计算(xqi,yqi)到各已知点的距离
            k=1; dist_min = dist(k);
            for j=2:length(dist)
                if(dist(j)<dist_min) dist_min = dist(j); k = j; end
            end
            P3 = [X1(k),Y1(k),V1(k)]; % 最近的1个点
        end
        
        P4 = [nan nan nan];
        if(sum(selector_RB)>0)
            X1 = X(selector_RB); Y1 = Y(selector_RB); V1 = V(selector_RB);  % 所有右下方的点
            dist = ((xq(i)-X1).^2 + (yq(i)-Y1).^2);  % 计算(xqi,yqi)到各已知点的距离
            k=1; dist_min = dist(k);
            for j=2:length(dist)
                if(dist(j)<dist_min) dist_min = dist(j); k = j; end
            end
            P4 = [X1(k),Y1(k),V1(k)]; % 最近的1个点
        end
        
        
        
        % 有一个方位不存在点，则这个方位的点用正上方或正下方的点地代替
%         if(isnan(P1)) 
%             P1 = P3;
%         elseif(isnan(P2)) 
%             P2 = P4; 
%         end
%         
%         if(isnan(P3)) 
%             P3 = P1;
%         elseif(isnan(P4)) 
%             P4 = P2; 
%         end
        q = [P1(3) P2(3) P3(3) P4(3)];
        if(any(isnan(q)))
            q = q(~isnan(q));
            vq(i)=mean(q);
            continue
        end
               

        %% step 3：在x方向插值，对P1和P2,在x=xqi处线性插值，得到点Q1(xqi,yi_1,vi_1);对P3和P4,在x=xi处线性插值，得到点Q2(xqi,yi_2,vi_2);
        % P1(x1,y1,v1),P2(x2,y2,v2)，插值点P(x,y,v)，v是要插值的参数
        % 线性插值计算公式 P = P1 + t*(P2 - P1)：① t = (x - x1)/(x2 - x1) ② y = y1 + t*(y2 - y1), z = z1 + t*(v2 - v1)   
        x1 = P1(1); y1 = P1(2); v1 = P1(3);
        x2 = P2(1); y2 = P2(2); v2 = P2(3);
        x3 = P3(1); y3 = P3(2); v3 = P3(3);
        x4 = P4(1); y4 = P4(2); v4 = P4(3);
%         if(abs((y2-y1)/(x2 - x1))<=2)
            t = (xq(i) - x1)/(x2 - x1);
%         else
%             t = 0.5; % 近似为中间点
%         end
        yi_1 = y1 + t*(y2 - y1);
        vi_1 = v1 + t*(v2 - v1);
        % Q1 = [xq(i),yi_1,vi_1];
%         if(abs((y4-y3)/(x4 - x3))<=2)
            t = (xq(i) - x3)/(x4 - x3);
%         else
%             t = 0.5; % 近似为中间点
%         end

        yi_2 = y3 + t*(y4 - y3);
        vi_2 = v3 + t*(v4 - v3);
        % Q2 = [xq(i),yi_2,vi_2];

        %% step 4: 在y方向插值，对Q1和Q2,在y=yi处线性插值，得到点Q(xqi,yqi,vqi);
        % zi是需要插值计算的参数
        % 线性插值计算公式 Q = Q1 + t*(Q2 - Q1)：① t = (yi - yi_1)/(yi_2 - yi_1) ② vqi = vi_1 + t*(vi_2 - vi_1)   
%         if(abs(yi_2 - yi_1)>Epsilon)
            t = (yq(i) - yi_1)/(yi_2 - yi_1);
%         else
%             t=0.5;
%         end
        vq(i) = vi_1 + t*(vi_2 - vi_1);
        
        %Q = [xq(i),yq(i),vq(i)];
        %disp(['i=',num2str(i),'  vq(i)=',num2str(vq(i))])
%         if(abs(vq(i))>2)
%             %disp(['i=',num2str(i),'  vq(i)=',num2str(vq(i))])
%             vq(i) = (vi_2 + vi_1)/2;
%         end
        

    end

end
