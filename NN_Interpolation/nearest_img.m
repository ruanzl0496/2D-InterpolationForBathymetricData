function newImg = nearest_img(img,scale)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%-----------------最近邻插值法缩放矩阵或图像---------------------
% 输入：
%       img--原始图像图像文件名或矩阵（整数值（0~255））
%       scale--缩放因子，即缩放的倍数,若为向量，则[scaleX,scaleY]
% 输出：
%       newImg--缩放后的图像矩阵 
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
if length(scale)==1  % 水平方向和垂向等比例缩放
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

%% Step3 最近邻插值
for j = 1:newWidth         % 对图像进行按列逐元素扫描。注意，不要逐行循环，否则非常非常慢，因为matlab按列序存储!
    v = round((j-1)/scaleX+1);
    for i = 1:newHeight % 本列中的所有元素
        u = round((i-1)/scaleY+1); % 四舍五入
        newImg(i,j,:) = img(u,v,:);  % 映射图像
    end
end

newImg = uint8(newImg);

end  