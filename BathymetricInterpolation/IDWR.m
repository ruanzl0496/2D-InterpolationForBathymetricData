function V = IDWR(x,y,v,X,Y,K)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% ɢ�����������ֵ���������Ȩ�ع�(Inverse distance weighted regression��IDWR)�㷨
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
    % dist = sqrt(dx.*dx+dy.*dy);
    dist = (dx.^2+dy.^2);  % �����ƽ��
    % �ҵ�K��������̵ĵ�
    [dist,IX] = sort(dist,'ascend'); % ��������
    d = dist(1:K);  % IX(1:K)Ϊ��K���������������еı������  
    if(any(d)<=epsilon) % ����㴦��
        V(j) = v(IX(1));
    else
        w = 1./d; %  �������K�����δ֪��(Xj,Yj)��Ȩ��
        D = sum(w); % Ȩ�غ�
        y_IDW = sum(w.*v(IX(1:K)))/D;% ����δ֪���IDWֵ
        V(j) = y_IDW + K*(sum(v(IX(1:K))) - K*y_IDW )/ (K^2 - sum(d)*D);
    end
end
end
