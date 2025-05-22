function V = IDW(x,y,v,X,Y,K)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% ɢ�����������ֵ���������Ȩ��Inverse Distance Weighted,IDW���㷨
% ���룺
%   x,y,v--ɢ����������
%   X,Y--Ϊδ֪����������,�����
%   K--�����Ȩ����ĵ������
% �����V--δ֪���ֵ���������
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%%
%N = length(x);  % ɢ�����
M = numel(X); % δ֪�����
%d = zeros(N,1); % ��ɢ��(xi,yi)��δ֪��(Xj,Yj)�ľ���
%w = d; % ��ɢ��(xi,yi)��δ֪��(Xj,Yj)��Ȩ��
V = zeros(size(X)); % δ֪���zֵ��Z(X,Y)
%%
epsilon = 1e-5; % ������0���Ƚϵ����
for j = 1:M  % ѭ������δ֪��
    % �����ɢ��(xi,yi)��δ֪��(Xj,Yj)�ľ���
    dx = x-X(j);  dy = y-Y(j);
    dist = dx.^2+dy.^2; % or sqrt(dx.^2+dy.^2);
    % �ҵ�K��������̵ĵ�
    [dist,IX] = sort(dist,'ascend'); % ��������
    d = dist(1:K);  % ǰK����С�ľ���  
    if(any(d)<=epsilon) % ����㴦��
        V(j) = v(IX(1));
    else
        w = 1./d; %  �������K�����δ֪��(Xj,Yj)��Ȩ��
        D = sum(w); % Ȩ�غ�
        V(j) = sum(w.*v(IX(1:K)))/D;% ����δ֪���ֵ��IX(1:K)Ϊ��K���������������еı������
    end
end
end
