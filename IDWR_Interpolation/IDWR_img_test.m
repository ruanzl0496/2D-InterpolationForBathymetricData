clear;
close all;
clc;
%%
scale = [4,2];
inFilename = 'squirrel.png';
tmp = strsplit(inFilename,'.');

outFilename = sprintf('IDWR_%s_x%s.%s',...
    tmp{1},replace(num2str(scale),'  ','_x'),tmp{2});
img = imread(inFilename); % 读取图像
img_new = IDWR_img(img,scale); % 通过IDW插值缩放图像
imgShow(img,img_new); % 显示图像

% 保存图像到文件
imwrite(img_new,outFilename);