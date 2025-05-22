% �������� 50 ��ɢ����������ݼ�����������ʹ�ý��ٵĵ�������Ŀ����Ϊ��ͻ����ֵ����֮��Ĳ��졣
clear all
close all
%%
rng(10) % ʹ������10��ʼ�������������
x = -3 + 6*rand(50,1);
y = -3 + 6*rand(50,1);
v = sin(x).^4 .* cos(y);
% ����һ����ѯ������

[Xq,Yq] = meshgrid(-3:0.1:3);
% ʹ�� 'nearest'��'linear'��'natural' �� 'cubic' ���������������ݡ����ƽ�����бȽϡ�
%vq = sin(Xq).^4 .* cos(Yq)
Vq = NNI(x,y,v,Xq,Yq);
plot3(x,y,v,'mo')
hold on
mesh(Xq,Yq,Vq) % ���Ʋ�ֵ����
% title('NNI')
legend('Sample Points','Interpolated Surface',...
    'Location','NorthWest')
set(gca, 'FontName','Times New Roman');
grid on

%% ����ԭʼ����
figure
V = sin(Xq).^4 .* cos(Yq);
mesh(Xq,Yq,V)
title('$z=\sin^{4}(x)\cos(y)$','interpreter','latex')
set(gca, 'FontName','Times New Roman');