function V = IDWR_depth(x,y,z,X,Y)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% ��������ˮ�����ݲ�ֵ���������Ȩ�ع飨Inverse Distance Weighted Regression,IDWR���㷨
% ���룺
%   x,y,v--���Ⱦ���������Ӧ������������һ����x���������ӵģ�y������ͬ�����ǵ�i�е�y������ڵ�i+1�е�y����
%   X,Y--Ϊδ֪����������,�����
%   K--�����Ȩ����ĵ������,�������4����
% �����V--δ֪���ֵ���������
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%%
N = length(x);  % ɢ�����
M = numel(X); % δ֪�����
epsilon = 1e-5; % ������0���Ƚϵ����

xRange = unique(x);% ����
yRange = flip(unique(y));% �ݼ�
DX = xRange(2)-xRange(1) ; % x����ֱ���
DY = yRange(2)-yRange(1); % y����ֱ��ʣ�һ����x��ͬ������Ϊ��ֵ
m = length(yRange); % ��Ϊ��Ⱦ��������
n = length(xRange); % ��Ϊ��Ⱦ��������
Z = transpose(reshape(z,[n,m])); % ��Ⱦ���
V = zeros(size(X)); % δ֪���zֵ��Z(X,Y)
%%
for j = 1:M  % ѭ������δ֪��
    % ȷ��X(j),Y(j)��Χ�����ɵ�
    selectorX = (X(j)-2*DX<=xRange & xRange<=X(j)+2*DX); % ѡ����������ѡȡ�õ����Ҿ�γ�Ȳ����2DX�����ɵ�
    selectorY = (Y(j)+2*DY<=yRange & yRange<=Y(j)-2*DY); % ѡ����������ѡȡ�õ����¾�γ�Ȳ����2DY�����ɵ�,ע��DY�Ǹ�ֵ
    x1 = xRange(selectorX);
    y1 = yRange(selectorY); 
    Z1 = Z(selectorY,selectorX);
    X1 = repmat(x1,size(Z1,1),1);
    Y1 = repmat(y1',1,size(Z1,2));
        
    % ����IDW��������δ֪�㣨X(j),Y(j)����ֵ
    K = numel(Z1);
    v = IDWR(X1(:),Y1(:),Z1(:),[X(j)],[Y(j)],K);  % ע�⣬�����ѯ����������һ���㣨X(j),Y(j)��
    V(j) = v(1);
end
end
