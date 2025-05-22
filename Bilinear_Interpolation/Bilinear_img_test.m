clear;
close all;
clc;
%%
scale = [4,2];
inFilename = 'squirrel.png';
tmp = strsplit(inFilename,'.');

outFilename = sprintf('Bilinear_%s_x%s.%s',...
    tmp{1},replace(num2str(scale),'  ','_x'),tmp{2});

img = imread(inFilename); % ��ȡͼ��
img_new = Bilinear_img(img,scale); % ͨ��˫���Խ���ֵ����ͼ��
img_show(img,img_new); % ��ʾͼ��

% ����ͼ���ļ�
imwrite(img_new,outFilename);