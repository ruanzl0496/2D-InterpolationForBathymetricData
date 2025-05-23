% ���ڽ���ֵ
% ��Ҫ˼�룺�ӵ�(x,y)��Χ��һ������ĵ㣬�õ��ֵ����Ϊ(x��y)���ֵ��
function V = NNI_depth(x,y,z,X,Y)
    % ��������ˮ�����ݲ�ֵ�����ڽ��㷨
    % ��֪���ݵ㣺x,y,v--���Ⱦ���������Ӧ������������һ����x���������ӵģ�y������ͬ�����ǵ�i�е�y������ڵ�i+1�е�y���꣬
    % ����ֵ�����㣺X,Y--���������
    % ���ز�ֵ�����V--���������

N = length(x);  % ɢ�����
M = numel(X); % δ֪�����

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
    % ȷ��X(j),Y(j)��xRange��yRang�е�ǰһ�����������,���õ���Χ��4����
    IX1 = fix((X(j)-xRange(1))/DX)+1;
    IY1 = fix((Y(j)-yRange(1))/DY)+1;
    IX2 = min(IX1+1,n);
    IY2 = min(IY1+1,m);
    Q11 = [xRange(IX1),yRange(IY1),Z(IY1,IX1)]; % ���Ͻ�
    Q12 = [xRange(IX2),yRange(IY1),Z(IY1,IX2)]; % ���Ͻ�
    Q21 = [xRange(IX1),yRange(IY2),Z(IY2,IX1)]; % ���½�
    Q22 = [xRange(IX2),yRange(IY2),Z(IY2,IX2)]; % ���½�
    
    % ����4�㵽δ֪��(Xj,Yj)�ľ����ƽ��
    d11 = (power(X(j)-Q11(1),2) + power(Y(j)-Q11(2),2));
    d12 = (power(X(j)-Q12(1),2) + power(Y(j)-Q12(2),2));
    d21 = (power(X(j)-Q21(1),2) + power(Y(j)-Q21(2),2));
    d22 = (power(X(j)-Q22(1),2) + power(Y(j)-Q22(2),2));
    
    dist = [d11, d12, d21, d22];
    depth = [Q11(3), Q12(3), Q21(3), Q22(3)]; % 4�ĸ�������
    
    % ������������
    [~,IX] = sort(dist);
    % �ҵ���������ĵ㣬�õ�������Ϊ��ѯ�����
    V(j) = depth(IX(1));
end
end