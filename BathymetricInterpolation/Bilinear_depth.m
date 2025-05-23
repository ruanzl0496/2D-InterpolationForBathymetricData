function V = Bilinear_depth(x,y,z,X,Y)
    % ��������ˮ�����ݲ�ֵ��˫�����㷨
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
       
    % ��x�����ֵ
    t1 = (X(j) - Q11(1))/DX; % DX = Q12(1)-Q11(1)
    T1 = Q11 + t1*(Q12-Q11);
    t2 = t1;
    T2 = Q21 + t2*(Q22-Q21);
    
    % ��y�����ֵ
    t = (Y(j)- T1(2))/DY; % DY = T2(2)-T1(2);
    V(j) = T1(3) + t*(T2(3)-T1(3));   
end
end