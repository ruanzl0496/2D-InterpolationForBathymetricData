function newImg = Bilinear_img(img,scale)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% 功能：双线性插值法缩放矩阵或图像
% 输入：img--原始图像图像文件名或矩阵
%       scale--缩放因子，即缩放的倍数,若为向量，则[scaleX,scaleY]
% 输出：newImg--缩放后的图像矩阵 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%% Step1 对数据进行预处理
if ~exist('img','var') || isempty(img)
    error('输入图像 I未定义或为空！');
end
if ~exist('scale','var') || isempty(scale) || numel(scale) >2
     error('位移矢量 scale未定义或为空或 scale中的元素超过2！');
end
if isstr(img)
    [img,M] = imread(img);
end
if any(scale) <= 0
     error('缩放倍数 scale的值应该大于0！');
end

%% Step2 通过原始图像和缩放因子得到新图像的大小，并创建新图像
[height,width,channel] = size(img);
if length(scale)==1
    scaleX = scale;
    scaleY = scale;
else
    scaleX = scale(1);
    scaleY = scale(2);
end
newHeight = round(height*scaleY); % 计算缩放后的图像高度，最近取整
newWidth = round(width*scaleX); % 计算缩放后的图像宽度，最近取整
newImg = zeros(newHeight,newWidth,channel); % 创建新图像
% 重新计算缩放系数。注意，传入的缩放系数指的是像素数量的比值，而在坐标轴上的第一个像素与最后一个像素之间的距离宽度比像素个数少1。
scaleX = (newWidth-1)/(width-1);
scaleY = (newHeight-1)/(height-1);

%% Step3 扩展圆图像边缘，底部和右侧各增加一行，以便边界像素点计算
imgEx = zeros(height+1,width+1,channel); 
imgEx(1:height,1:width,:) = img; % 复制原图到扩展图
imgEx(height+1,1:width,:) = img(height,:,:); % 原图的最后一行复制到扩展图最后一行
imgEx(1:height,width+1,:) = img(:,width,:);% 原图的最后一列复制到扩展图最后一列
imgEx(height+1,width+1,:) = img(height,width,:);% 原图的右下角像素复制到扩展图右下角

%% ============================================================
% Step4 由新图像的第i行j列个像素（j，i）映射到原始图像(u1，v1)处， 并在原始
% 图像的(u1,v1)位置利用其周围4个像素点进行插值得到该点的像素值
% 这4个点分别为：左上角(u,  v),   右上角(u+1,  v)
%               左下角(u,v+1),   右下角(u+1,v+1)
% % ====================================================================
for j = 1:newWidth         % 对图像进行按列逐元素扫描
    u1 = (j-1)/scaleX+1;
    u = floor(u1);
    dx = u1 - u;  % 对同一列像素，v1,v,dx是固定的,因此不必放到内层循环中重复计算
    for i = 1:newHeight
        % (i,j)表示在新图中的坐标，(u1,v1)表示在原图中的坐标
        % 注意：(u1,v1)不一定是整数
        v1 = (i-1)/scaleY+1; 
        v = floor(v1); 
        dy = v1 - v;
        
        % 在x方向线性插值
        t1 = dx; t2 = dx;
        Z1 = imgEx(v,u,:) + t1*(imgEx(v,u+1,:) - imgEx(v,u,:));
        Z2 = imgEx(v+1,u,:) + t2*(imgEx(v+1,u+1,:) - imgEx(v+1,u,:));
        % 在y方向线性插值
        t = dy;
        newImg(i,j,:) = Z1 + t*(Z2-Z1);      
    end
end
newImg = uint8(newImg);
end  