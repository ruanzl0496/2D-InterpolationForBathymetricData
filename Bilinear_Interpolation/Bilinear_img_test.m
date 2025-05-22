clear;
close all;
clc;
%%
scale = [4,2];
inFilename = 'squirrel.png';
tmp = strsplit(inFilename,'.');

outFilename = sprintf('Bilinear_%s_x%s.%s',...
    tmp{1},replace(num2str(scale),'  ','_x'),tmp{2});

img = imread(inFilename); % 读取图像
img_new = Bilinear_img(img,scale); % 通过双线性近插值缩放图像
img_show(img,img_new); % 显示图像

% 保存图像到文件
imwrite(img_new,outFilename);