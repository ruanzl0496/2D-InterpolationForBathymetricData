clear;
close all;
clc;
%%
scale = [4,2];
inFilename = 'squirrel.png';
tmp = strsplit(inFilename,'.');
outFilename = sprintf('NNI_%s_x%s.%s',...
    tmp{1},replace(num2str(scale),'  ','_x'),tmp{2});
img = imread(inFilename); % ��ȡͼ��
imgNew = nearest_img(img,scale); % ͨ�����ڽ���ֵ����ͼ��
imgShow(img,imgNew); % ��ʾͼ��

% ����ͼ���ļ�
imwrite(imgNew,outFilename);