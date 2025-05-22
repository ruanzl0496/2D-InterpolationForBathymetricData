function imgShow(img,newImg)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% 功能：绘制缩放前后的两幅图像
% 输入：img--原始图像
%       newImg--缩放后的图像
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
[height,width,~] = size(img);% [height,width,channel] = size(img);
figure;
imshow(img);
axis on
title(['Source image (',num2str(width),'\times',num2str(height),')']);
ax=gca;
ax.Position=[0.05    0.12    0.9    0.76];

[newHeight,newWidth,~] =size(newImg); 
figure;
imshow(newImg);
axis on
title(['Scaled image (',num2str(newWidth),'\times',num2str(newHeight),')']);
ax=gca;
ax.Position=[0.05    0.1    0.9    0.8];
end