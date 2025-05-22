% �������� 50 ��ɢ����������ݼ�����������ʹ�ý��ٵĵ�������Ŀ����Ϊ��ͻ����ֵ����֮��Ĳ��졣
clear all
close all
rng(10) % ʹ������10��ʼ�������������
X = -3 + 6*rand(50,1);
Y = -3 + 6*rand(50,1);
V = sin(X).^4 .* cos(Y);
% ����һ����ѯ������
[xq,yq] = meshgrid(-3:0.1:3);

Ks = [2,4,8,16,32];
for i = 1:length(Ks)
    K = Ks(i);
    vq = IDWR(X,Y,V,xq,yq,K);  
    
    figure
    plot3(X,Y,V,'mo')
    hold on
    mesh(xq,yq,vq)
    title(['$K=',num2str(K),'$'],'interpreter','latex')
    legend('Sample Points','Interpolated Surface','Location','NorthWest')
    set(gca, 'FontName','Times New Roman');
    grid on
end

%% ����ԭʼ����
figure
vq = sin(xq).^4 .* cos(yq);
mesh(xq,yq,vq)
title('$z=\sin^{4}(x)\cos(y)$','interpreter','latex')
set(gca, 'FontName','Times New Roman');